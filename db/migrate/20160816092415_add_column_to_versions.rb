class AddColumnToVersions < ActiveRecord::Migration[5.0]
  def change
    add_column :versions, :organization_name, :string
    add_column :versions, :project_name, :string
    add_column :versions, :title, :string
  end
end