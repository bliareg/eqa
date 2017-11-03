class AddLinkToMobileBuild < ActiveRecord::Migration[5.0]
  def change
    add_column :mobile_builds, :link, :string
  end
end
