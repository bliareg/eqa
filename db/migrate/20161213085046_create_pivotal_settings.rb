class CreatePivotalSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :pivotal_settings do |t|
      t.string :project_name
      t.integer :service_project_id
      t.string :api_token
      t.boolean :enable_synchronization, default: true
      t.integer :synchronization_type
      t.references :user, foreign_key: true
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
