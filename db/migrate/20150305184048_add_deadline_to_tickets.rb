class AddDeadlineToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :deadline, :timestamp
  end
end
