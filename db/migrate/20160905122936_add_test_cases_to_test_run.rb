class AddTestCasesToTestRun < ActiveRecord::Migration[5.0]
  def change
    add_column :test_runs, :test_cases, :text, array: true, default: []
  end
end
