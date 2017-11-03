class RemoveColumnsFromProjectsOrganizations < ActiveRecord::Migration[5.0]
  def up
    remove_attachment :projects, :logo
    remove_attachment :organizations, :logo
  end

  def down
    add_attachment :projects, :logo
    add_attachment :organizations, :logo
  end
end
