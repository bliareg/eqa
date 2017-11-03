class AddEditorToTestModules < ActiveRecord::Migration[5.0]
  def change
    add_reference :test_modules, :editor, references: :user
  end
end
