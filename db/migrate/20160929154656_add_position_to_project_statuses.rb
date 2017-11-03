class AddPositionToProjectStatuses < ActiveRecord::Migration[5.0]
  def change
    add_column :project_statuses, :position, :integer
  end
end
