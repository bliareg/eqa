class AddDeletedAtToTestPlansModulesAndCases < ActiveRecord::Migration[5.0]
  def change
    add_column :test_cases, :deleted_at, :datetime
    add_index :test_cases, :deleted_at

    add_column :test_modules, :deleted_at, :datetime
    add_index :test_modules, :deleted_at

    add_column :test_plans, :deleted_at, :datetime
    add_index :test_plans, :deleted_at
  end
end
