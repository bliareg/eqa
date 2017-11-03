class AddCrashReferencesToComments < ActiveRecord::Migration[5.0]
  def change
    add_reference :comments, :crash, foreign_key: true
  end
end
