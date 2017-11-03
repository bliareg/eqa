class CreateProjectStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :project_statuses do |t|
      t.integer :project_id
      t.integer :status_id
      t.boolean :show, default: true

      t.timestamps
    end
  end
end
