class DestroyTestPlanIdColumnFromTestRuns < ActiveRecord::Migration[5.0]
  def change
    remove_column :test_runs, :test_plan_id, :integer
  end
end
