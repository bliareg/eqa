class AddColumnsToTestCase < ActiveRecord::Migration[5.0]
  def change
    add_column :test_cases, :module_name, :string
    add_column :test_cases, :parent_module_name, :string
  end
end
