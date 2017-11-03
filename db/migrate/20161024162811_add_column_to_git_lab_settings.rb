class AddColumnToGitLabSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :git_lab_settings, :enable_synchronization, :boolean, default: true
    add_column :git_lab_settings, :synchronization_type, :integer
    add_column :git_lab_settings, :project_url, :string
    add_reference :git_lab_settings, :user, index: true
  end
end
