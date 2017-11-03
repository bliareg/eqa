class CreateTestRunModules < ActiveRecord::Migration[5.0]
  def change
    create_table :test_run_modules do |t|
      t.integer  :test_run_id
      t.integer  :test_module_id
      t.integer  :assigned_to
      t.timestamps
    end
  end
end
