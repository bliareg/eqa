class CreateProjectNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :project_notifications do |t|
      t.boolean :turn_on, default: true
      t.references :project, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
