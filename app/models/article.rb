class Article < ActiveRecord::Base

  validates_presence_of :title, :description, :body

  attr_accessor :labels_list

  after_save :update_labels
  after_initialize :set_labels_list

  has_many :labelings, as: :labelable, dependent: :destroy
  has_many :labels, through: :labelings
  has_many :ticket_articles
  has_many :tickets, through: :ticket_articles
  has_many :attachments, as: :attachable, dependent: :destroy
  accepts_nested_attributes_for :attachments, allow_destroy: true, :reject_if => lambda { |a| a[:file].blank? }

  scope :search, ->(term) {
    if !term.nil?
      term.gsub!(/[\\%_]/) { |m| "!#{m}" }
      term = "%#{term.downcase}%"
      articles_ids = Label.where('LOWER(name) LIKE ? ESCAPE ?', term, '!').collect(&:articles).collect(&:first).reject(&:blank?).collect(&:id)
      where('LOWER(title) LIKE ? ESCAPE ? OR LOWER(description) LIKE ? ESCAPE ? OR LOWER(body) LIKE ? ESCAPE ? OR id IN (?)',
                         term, '!', term, '!', term, '!', articles_ids).uniq
    end
  }

  scope :ordered, -> {
    order(:created_at).reverse_order
  }

  scope :by_label_id, ->(label_id) {
    if label_id.to_i > 0
      joins(:labelings).where(labelings: { label_id: label_id })
    end
  }

  scope :sorted, lambda { |param, direction|
    parts = param.split('.')
    direction = direction == 'asc' ? 'asc' : 'desc'

    if parts.count == 1 && Article.column_names.include?(parts.first)
      order(parts.first + ' ' + direction)
    elsif parts.count > 1
      attr = parts.pop
      assoc_hash = parts.reverse.inject({}) { |a, n| { n => a } }
      includes(assoc_hash).references(assoc_hash).order(attr + ' ' + direction)
    end
  }

  private
  def set_labels_list
    self.labels_list ||= self.labels.pluck(:name).join(',')
  end

  def update_labels
    unless self.labels_list.blank?
      self.labels = self.labels_list.split(',').map do |label|
        Label.where(name: label.strip).first_or_create
      end
    end
    true
  end

end
