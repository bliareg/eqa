class CreateJiraSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :jira_settings do |t|
      t.string :base_url
      t.string :site
      t.string :context_path
      t.string :username
      t.string :password
      t.boolean :enable_synchronization, default: true
      t.integer :synchronization_type
      t.string :board_name
      t.integer :board_id
      t.boolean :sprint_support
      t.string :project_key
      t.references :project, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
