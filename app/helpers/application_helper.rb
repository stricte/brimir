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

# helpers used system wide
module ApplicationHelper

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == params[:sort] ? "current #{params[:direction]} sort-trigger" : nil
    direction = column == params[:sort] && params[:direction] == "asc" ? "desc" : "asc"
    link_to title, params.merge({:sort => column, :direction => direction}), {:class => css_class}
  end

  def role(user)
    if user.admin?
      t(:admin)
    elsif user.agent?
      t(:agent)
    else
      t(:customer)
    end
  end

  def active_elem_if(elem, condition, attributes = {}, &block)
    if condition
      # define class as empty string when no class given
      attributes[:class] ||= ''
      # add 'active' class
      attributes[:class] += ' active'
    end

    # return the content tag with possible active class
    content_tag(elem, attributes, &block)
  end

  # change the default link renderer for will_paginate
  def will_paginate(collection_or_options = nil, options = {})
    if collection_or_options.is_a? Hash
      options, collection_or_options = collection_or_options, nil
    end
    unless options[:renderer]
      options = options.merge renderer: Pagination::PaginationRenderer
    end
    super(*[collection_or_options, options].compact)
  end

  def status_icon(status)
    if status == 'closed'
      'check'
    elsif status == 'deleted'
      'trash-o'
    elsif status == 'waiting'
      'clock-o'
    else
      'inbox'
    end
  end

  def ticket_background_color(ticket)
  color = case ticket.priority
          when 'unknown' then '#ccc'
          when 'low' then '#ffd700'
          when 'medium' then '#ff8000'
          when 'high' then '#da1500'
          else ''
          end
  color
end
end
