class CreateTestRunResults < ActiveRecord::Migration[5.0]
  def change
    create_table :test_run_results do |t|
      t.integer  :test_run_id
      t.integer  :test_module_id
      t.integer  :test_case_id
      t.integer  :status
      t.integer  :passed_by
      t.timestamps
    end
  end
end
