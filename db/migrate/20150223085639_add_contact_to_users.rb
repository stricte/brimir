class AddContactToUsers < ActiveRecord::Migration
  def change
    add_column :users, :contact, :text
  end
end
