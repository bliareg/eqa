class RemoveOrganizationNameFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :organization_name, :string
  end
end
