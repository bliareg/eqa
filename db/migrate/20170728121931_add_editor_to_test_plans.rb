class AddEditorToTestPlans < ActiveRecord::Migration[5.0]
  def change
    add_reference :test_plans, :editor, references: :user
  end
end
