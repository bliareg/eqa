class AddFieldsToAdminUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :admin_users, :superadmin, :boolean, default: false
    add_column :admin_users, :created_by_id, :integer
  end
end
