class CreateTestPlans < ActiveRecord::Migration[5.0]
  def change
    create_table :test_plans do |t|
      t.integer  :project_id
      t.integer  :created_by
      t.string   :title
      t.string   :description
      t.timestamps
    end
  end
end
