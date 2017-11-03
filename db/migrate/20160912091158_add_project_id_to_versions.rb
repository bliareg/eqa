class AddProjectIdToVersions < ActiveRecord::Migration[5.0]
  def change
    add_column :versions, :project_id, :integer
    remove_column :versions, :project_name, :string
    remove_column :versions, :organization_name, :string
  end
end
