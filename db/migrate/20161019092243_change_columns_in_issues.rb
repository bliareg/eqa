class ChangeColumnsInIssues < ActiveRecord::Migration[5.0]
  def change
    change_column :issues, :issue_type, :integer, default: 0
    change_column :issues, :severity, :integer, default: 0
    change_column :issues, :priority, :integer, default: 0
  end
end
