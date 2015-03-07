class AddLabelsCountToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :labels_count, :integer, default: 0
  end
end
