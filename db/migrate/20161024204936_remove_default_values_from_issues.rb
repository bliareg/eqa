class RemoveDefaultValuesFromIssues < ActiveRecord::Migration[5.0]
  def change
    change_column_default :issues, :issue_type, nil
    change_column_default :issues, :severity, nil
    change_column_default :issues, :priority, nil
  end
end
