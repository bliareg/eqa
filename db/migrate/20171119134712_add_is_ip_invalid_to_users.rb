class AddIsIpInvalidToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :is_ip_invalid, :boolean
  end
end
