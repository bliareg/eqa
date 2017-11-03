class CreateGitLabSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :git_lab_settings do |t|
      t.references :project, foreign_key: true
      t.string :base_url
      t.integer :service_project_id
      t.string :access_token

      t.timestamps
    end
  end
end
