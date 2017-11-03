class AddCrashReferencesToIssues < ActiveRecord::Migration[5.0]
  def change
    add_reference :issues, :crash, foreign_key: true
  end
end
