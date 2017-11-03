class CreateRedmineSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :redmine_settings do |t|
      t.string :base_url
      t.string :api_key
      t.string :project_name
      t.integer :service_project_id
      t.string :tracker_name
      t.integer :tracker_id
      t.boolean :enable_synchronization, default: true
      t.integer :synchronization_type
      t.references :project, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
