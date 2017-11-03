class RenameMobileBuildsTable < ActiveRecord::Migration[5.0]
  def change
    rename_table :mobile_builds, :test_objects
    rename_column :issues, :mobile_build_id, :test_object_id
    rename_column :crashes, :mobile_build_id, :test_object_id
    rename_column :ios_build_plists, :mobile_build_id, :test_object_id
  end
end
