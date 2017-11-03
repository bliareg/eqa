class AddBranchNameToGitSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :git_hub_settings, :branch, :string, default: 'master'
    add_column :git_lab_settings, :branch, :string, default: 'master'
  end
end
