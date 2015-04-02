class AddStartTimeToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :start_time, :timestamp
  end
end
