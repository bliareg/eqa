class AddProjectIssueNumberToIssues < ActiveRecord::Migration[5.0]
  def change
    add_column :issues, :project_issue_number, :integer
    add_index :issues, :project_issue_number
  end
end
