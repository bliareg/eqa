class AddPositionToTestCases < ActiveRecord::Migration[5.0]
  def change
    add_column :test_cases, :position, :integer
  end
end
