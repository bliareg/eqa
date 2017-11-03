class AddIdInProjectToTestCases < ActiveRecord::Migration[5.0]
  def change
    add_column :test_cases, :id_in_project, :integer
  end
end
