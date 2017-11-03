class CreateGitHubSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :git_hub_settings do |t|
      t.string :repository_url
      t.string :access_token
      t.string :base_url
      t.string :repository_name
      t.references :project, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :enable_synchronization, default: true
      t.integer :synchronization_type

      t.timestamps
    end
  end
end
