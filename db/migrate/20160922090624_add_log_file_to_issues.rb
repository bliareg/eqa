class AddLogFileToIssues < ActiveRecord::Migration[5.0]
  def change
    add_reference :issues, :log_file, foreign_key: true
  end
end
