class CreateTestCases < ActiveRecord::Migration[5.0]
  def change
    create_table :test_cases do |t|
      t.integer  :test_plan_id
      t.integer  :module_id
      t.integer  :updated_by
      t.string   :title
      t.string   :selection
      t.integer  :case_type
      t.string   :pre_steps
      t.string   :steps
      t.string   :expected_result
      t.timestamps
    end
  end
end
