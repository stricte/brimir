class AddRepliesCountToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :replies_count, :integer, default: 0
  end
end
