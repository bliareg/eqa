class AddUsernameToGitSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :git_hub_settings, :username, :string
    add_column :git_lab_settings, :username, :string
  end
end
