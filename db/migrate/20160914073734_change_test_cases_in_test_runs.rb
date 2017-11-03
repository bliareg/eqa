class ChangeTestCasesInTestRuns < ActiveRecord::Migration[5.0]
  def self.up
    remove_column :test_runs, :test_cases
    add_column :test_runs, :test_cases, :hstore
  end
  def self.down
    remove_column :test_runs, :test_cases
    add_column :test_runs, :test_cases, :text, array: true, default: []
  end
end
