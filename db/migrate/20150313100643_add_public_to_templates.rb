class AddPublicToTemplates < ActiveRecord::Migration
  def change
    add_column :templates, :public, :boolean, default: false
  end
end
