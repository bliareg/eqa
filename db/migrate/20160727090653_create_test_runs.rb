class CreateTestRuns < ActiveRecord::Migration[5.0]
  def change
    create_table :test_runs do |t|
      t.integer  :test_plan_id
      t.integer  :project_id
      t.integer  :assigned_to
      t.string   :title
      t.string   :description
      t.timestamps
    end
  end
end
