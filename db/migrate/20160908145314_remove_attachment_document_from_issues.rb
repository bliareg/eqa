class RemoveAttachmentDocumentFromIssues < ActiveRecord::Migration[5.0]
  def self.up
    remove_attachment :issues, :document
  end

  def self.down
    add_attachment :issues, :document
  end
end
