class AddRunStatusToTestRuns < ActiveRecord::Migration[5.0]
  def change
    add_column :test_runs, :run_status, :integer
    add_index :test_runs, :run_status
  end
end
