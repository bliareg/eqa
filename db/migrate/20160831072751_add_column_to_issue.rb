class AddColumnToIssue < ActiveRecord::Migration[5.0]
  def change
    add_reference :issues, :mobile_build, foreign_key: true
  end
end
