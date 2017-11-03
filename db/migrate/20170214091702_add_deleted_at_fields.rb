class AddDeletedAtFields < ActiveRecord::Migration[5.0]
  def change
    add_column :log_files, :deleted_at, :datetime
    add_index :log_files, :deleted_at

    add_column :test_objects, :deleted_at, :datetime
    add_index :test_objects, :deleted_at

    add_column :crashes, :deleted_at, :datetime
    add_index :crashes, :deleted_at

    add_column :issues, :deleted_at, :datetime
    add_index :issues, :deleted_at

    add_column :git_lab_settings, :deleted_at, :datetime
    add_index :git_lab_settings, :deleted_at

    add_column :git_hub_settings, :deleted_at, :datetime
    add_index :git_hub_settings, :deleted_at

    add_column :you_track_settings, :deleted_at, :datetime
    add_index :you_track_settings, :deleted_at

    add_column :jira_settings, :deleted_at, :datetime
    add_index :jira_settings, :deleted_at

    add_column :pivotal_settings, :deleted_at, :datetime
    add_index :pivotal_settings, :deleted_at

    add_column :redmine_settings, :deleted_at, :datetime
    add_index :redmine_settings, :deleted_at
  end
end
