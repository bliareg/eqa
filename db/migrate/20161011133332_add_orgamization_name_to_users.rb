class AddOrgamizationNameToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :organization_name, :string
  end
end
