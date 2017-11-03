class RemoveUnusedColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :test_modules, :type, :string
    remove_column :test_modules, :updated_by, :integer
    remove_column :test_cases, :module_name, :string
    remove_column :test_cases, :parent_module_name, :string
    remove_column :test_cases, :selection, :string
  end
end
