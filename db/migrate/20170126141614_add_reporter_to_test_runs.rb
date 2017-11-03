class AddReporterToTestRuns < ActiveRecord::Migration[5.0]
  def change
    add_reference :test_runs, :reporter, references: :user
    rename_column :test_runs, :assigned_to, :assigner_id
    remove_column :test_runs, :test_cases, :hstore
    remove_column :test_run_results, :test_module_id, :integer
  end
end
