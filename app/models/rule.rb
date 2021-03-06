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

# filter rules applied to a ticket when it is created
class Rule < ActiveRecord::Base
  validates :filter_field, :filter_value, presence: true

  enum filter_operation: [:contains]
  enum action_operation: [:assign_label, :notify_user, :change_status,
                          :change_priority, :assign_user, :post_to_slack,
                          :change_group]

  def filter(ticket)
    if ticket.respond_to?(filter_field)
      value = ticket.send(filter_field).to_s
    else
      value = ticket.attributes[filter_field].to_s
    end

    (filter_value == '*' || value.mb_chars.downcase.include?(filter_value.mb_chars.downcase)) if filter_operation == 'contains'
  end

  def execute(ticket)
    if action_operation == 'assign_label'
      label = Label.where(name: action_value).first_or_create
      ticket.labels << label

    elsif action_operation == 'notify_user'
      user = User.where(email: action_value).first

      ticket.notified_users << user unless user.nil?

    elsif action_operation == 'change_status'
      ticket.status = action_value
      ticket.save

    elsif action_operation == 'change_priority'
      ticket.priority = action_value
      ticket.save

    elsif action_operation == 'assign_user'
      user = User.where(email: action_value).first

      unless user.nil?
        ticket.assignee = user
        ticket.save
      end

    elsif action_operation == 'post_to_slack'
      notifier = Slack::Notifier.new action_value, username: "#{Site.title} (#{Site.domain})"
      notifier.ping I18n.t(:slack_new_ticket_info, domain: Site.domain, title: Site.title, ticket_subject: ticket.subject, ticket_from: ticket.user.email), http_options: { open_timeout: 5 }

    elsif action_operation == 'change_group'
      group = Group.where(name: action_value).first

      if group
        ticket.group_id = group.id
        ticket.save
      end
    end
  end

  def self.apply_all(ticket, delayed = true)
    if delayed
      RuleExecutorJob.perform_later(ticket)
    else
      RuleExecutorJob.perform_now(ticket)
    end
  end
end
