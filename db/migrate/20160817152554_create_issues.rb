class CreateIssues < ActiveRecord::Migration[5.0]
  def change
    create_table :issues do |t|
      t.string :summary
      t.string :description
      t.integer :project_id
      t.integer :issue_type
      t.integer :severity
      t.integer :priority
      t.integer :status_id, default: 1
      t.integer :reporter_id
      t.integer :assigner_id

      t.timestamps
    end
  end
end
