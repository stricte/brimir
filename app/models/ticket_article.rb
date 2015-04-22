class TicketArticle < ActiveRecord::Base
  belongs_to :ticket
  belongs_to :article
end
