class AddAttachmentDocumentToIssues < ActiveRecord::Migration
  def self.up
    change_table :issues do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :issues, :document
  end
end
