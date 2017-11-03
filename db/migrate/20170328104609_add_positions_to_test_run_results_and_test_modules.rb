class AddPositionsToTestRunResultsAndTestModules < ActiveRecord::Migration[5.0]
  def change
    add_column :test_modules, :position, :integer, default: 0
    add_column :test_run_results, :position, :integer, default: 0
  end
end
