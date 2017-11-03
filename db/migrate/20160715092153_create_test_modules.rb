class CreateTestModules < ActiveRecord::Migration[5.0]
  def change
    create_table :test_modules do |t|
      t.integer  :test_plan_id
      t.integer  :created_by
      t.string   :title
      t.string   :description
      t.string   :type
      t.integer  :updated_by
      t.integer  :parent_id, :null => true, :index => true
      t.integer  :lft, :null => false, :index => true
      t.integer  :rgt, :null => false, :index => true
      t.integer  :depth
      t.integer  :children_count
      t.timestamps
    end
  end
end
