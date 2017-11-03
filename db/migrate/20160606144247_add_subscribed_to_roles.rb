class AddSubscribedToRoles < ActiveRecord::Migration[5.0]
  def change
    add_column :roles, :is_subscribed, :boolean
  end
end
