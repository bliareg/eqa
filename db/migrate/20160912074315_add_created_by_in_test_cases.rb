class AddCreatedByInTestCases < ActiveRecord::Migration[5.0]
  def change
    add_column :test_cases, :created_by, :integer
  end
end
