class RemovePlatformFromProjects < ActiveRecord::Migration[5.0]
  def change
    remove_column :projects, :platform, :string
  end
end
