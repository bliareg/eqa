class ChangeStatusColorLogic < ActiveRecord::Migration[5.0]
  def change
    remove_column :statuses, :color, :string
    change_column :statuses, :name,  :string, default: 'New status'
    add_column :project_statuses, :color, :integer, default: 1
  end
end
