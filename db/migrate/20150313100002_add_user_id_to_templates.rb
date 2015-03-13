class AddUserIdToTemplates < ActiveRecord::Migration
  def change
    add_column :templates, :user_id, :integer
  end
end
