class AddTimestampToOrganizationsAndProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :created_at, :timestamp, null: false
    add_column :organizations, :updated_at, :timestamp, null: false

    add_column :projects, :created_at, :timestamp, null: false
    add_column :projects, :updated_at, :timestamp, null: false
  end
end
