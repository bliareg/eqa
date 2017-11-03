class AddColumnsToMobileBuilds < ActiveRecord::Migration[5.0]
  def change
    add_column :mobile_builds, :platform_version, :string
    add_column :mobile_builds, :package, :string
    add_column :mobile_builds, :min_sdk_version, :string
    add_column :mobile_builds, :sdk_version, :string
  end
end
