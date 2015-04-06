class AddEndTimeToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :end_time, :timestamp
  end
end
