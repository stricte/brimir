class CreateTicketArticles < ActiveRecord::Migration
  def change
    create_table :ticket_articles do |t|
      t.integer :ticket_id
      t.integer :article_id

      t.timestamps null: false
    end
  end
end
