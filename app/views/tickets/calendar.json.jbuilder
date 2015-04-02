json.array! @tickets do |ticket|

  json.id ticket.id
  json.title (ticket.subject.blank? ? t(:no_subject) : ticket.subject) + ' (' + ticket.user.email  + ')'
  json.start ticket.start_time.iso8601
  json.end ticket.end_time.iso8601 if ticket.end_time
  json.url ticket_path(ticket)
  json.class ['ticket','event',ticket.status, ticket.priority]
  json.backgroundColor ticket_background_color(ticket)
  json.borderColor ticket_background_color(ticket)
  json.textColor '#626262'
end
