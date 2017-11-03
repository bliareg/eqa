class AddTestCaseReferenceToIssues < ActiveRecord::Migration[5.0]
  def change
    add_reference :issues, :test_case, foreign_key: true
  end
end
