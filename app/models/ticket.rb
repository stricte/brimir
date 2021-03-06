# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2015 Ivaldi http://ivaldi.nl
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class Ticket < ActiveRecord::Base
  include CreateFromUser

  validates_presence_of :user_id

  belongs_to :user
  belongs_to :assignee, class_name: 'User'
  belongs_to :group

  has_many :attachments, as: :attachable, dependent: :destroy
  accepts_nested_attributes_for :attachments, allow_destroy: true

  has_many :replies, dependent: :destroy
  has_many :labelings, as: :labelable, dependent: :destroy
  has_many :labels, through: :labelings

  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :notified_users, source: :user, through: :notifications

  has_many :status_changes, dependent: :destroy

  has_many :ticket_articles
  has_many :articles, through: :ticket_articles

  enum status: [:open, :closed, :deleted, :waiting]
  enum priority: [:unknown, :low, :medium, :high]

  after_update :log_status_change
  after_create :create_status_change

  before_save :set_time_consumed
  before_save :change_sender
  before_create :set_default_group
  after_create :create_labels
  after_create :set_start_time
  after_save :set_end_time
  after_save :update_linked_articles

  attr_accessor :consumed_days, :consumed_hours, :consumed_minutes
  attr_accessor :sender
  attr_accessor :labels_list
  attr_accessor :articles_ids

  def self.active_labels(status)
    label_ids = where(status: Ticket.statuses[status])
        .joins(:labelings)
        .pluck(:label_id)
        .uniq

    return Label.where(id: label_ids)
  end

  scope :by_label_id, ->(label_id) {
    if label_id.to_i > 0
      joins(:labelings).where(labelings: { label_id: label_id })
    end
  }

  scope :by_status, ->(status) {
    where(status: Ticket.statuses[status.to_sym])
  }

  scope :filter_by_assignee_id, ->(assignee_id) {
    if !assignee_id.nil?
      if assignee_id.to_i == 0
        where(assignee_id: nil)
      else
        where(assignee_id: assignee_id)
      end
    else
      all
    end
  }

  scope :search, ->(term) {
    if !term.nil?
      term.gsub!(/[\\%_]/) { |m| "!#{m}" }
      term = "%#{term.downcase}%"
      tickets_ids = Label.where('LOWER(name) LIKE ? ESCAPE ?', term, '!').collect(&:tickets).flatten.collect{|t| t.id}
      joins(:user).where('LOWER(subject) LIKE ? ESCAPE ? OR LOWER(content) LIKE ? ESCAPE ? OR LOWER(users.email) LIKE ? ESCAPE ? OR tickets.id IN (?)',
          term, '!', term, '!', term, '!', tickets_ids)
    end
  }

  scope :ordered, -> {
    order(:created_at).reverse_order
  }

  scope :viewable_by, ->(user) {
    if user.agent?
      where("group_id IN (?) OR tickets.assignee_id = ? OR (group_id IS NULL AND tickets.assignee_id IS NULL)", user.group_ids, user.id)
    elsif user.customer?
      ticket_ids = Labeling.where(label_id: user.label_ids)
          .where(labelable_type: 'Ticket')
          .pluck(:labelable_id)
      where('tickets.id IN (?) OR tickets.user_id = ?', ticket_ids, user.id)
    end
  }

  scope :sorted, lambda { |param, direction|
    parts = param.split('.')
    direction = direction == 'asc' ? 'asc' : 'desc'

    if parts.count == 1 && Ticket.column_names.include?(parts.first)
      order(parts.first + ' ' + direction)
    elsif parts.count > 1
      attr = parts.pop
      assoc_hash = parts.reverse.inject({}) { |a, n| { n => a } }
      includes(assoc_hash).references(assoc_hash).order(attr + ' ' + direction)
    end
  }

  scope :events, lambda { |start, stop|
    where("start_time <= ? AND (end_time >= ? OR end_time IS NULL)", stop, start)
  }

  def set_default_notifications!
    self.notified_user_ids = User.agents_to_notify(group_id).pluck(:id)
  end

  def status_times
    total = {}

    Ticket.statuses.keys.each do |key|
      total[key.to_sym] = 0
    end

    status_changes.each do |status_change|
      total[status_change.status.to_sym] += status_change.updated_at - status_change.created_at
    end

    # add the current status as well
    current = status_changes.ordered.last
    unless current.nil?
      total[current.status.to_sym] += Time.now - current.created_at
    end

    Ticket.statuses.keys.each do |key|
      total[key.to_sym] /= 1.minute
    end

    total
  end

  def time_consumed_as_duration
    Duration.new(time_consumed*60)
  end

  #Suggested through labels
  def suggested_articles
    self.labels.joins(:articles).collect(&:articles).collect(&:first).uniq
  end

  protected

  def update_linked_articles
    unless self.articles_ids.nil?
      self.articles = Article.where(id: self.articles_ids)
    end
  end

  def set_start_time
    self.update_column(:start_time, self.created_at)
  end

  def set_end_time
    if status == 'closed'
      change_status_time = self.status_changes.order('updated_at DESC').first.try(:updated_at)
      self.update_column(:end_time, change_status_time)
    end
  end

  def create_labels
    self.labels_list.split(',').each do |label|
      self.labelings.create({label: {name: label.strip}})
    end unless self.labels_list.blank?
  end

  def set_default_group
    default_group = Group.where(default: true).first
    self.group_id = default_group.id if (default_group && self.group_id.nil?)
  end

  def change_sender
    self.from = self.sender if self.sender && self.sender.match(Devise.email_regexp)
  end

  def set_time_consumed
    self.time_consumed = Duration.new(:days => self.consumed_days.to_i, :hours => self.consumed_hours.to_i, :minutes => self.consumed_minutes.to_i).total/60 if self.consumed_days || self.consumed_hours || self.consumed_minutes
  end

  def create_status_change
    status_changes.create! status: self.status
  end

  def log_status_change

    if self.changed.include? 'status'
      previous = status_changes.ordered.last

      unless previous.nil?
        previous.updated_at = Time.now
        previous.save
      end

      status_changes.create! status: self.status
    end
  end

end
