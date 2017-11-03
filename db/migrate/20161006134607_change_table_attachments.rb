class ChangeTableAttachments < ActiveRecord::Migration[5.0]
  def change
    change_table :attachments do |t|
      t.remove :issue_id
      t.references :attachable, polymorphic: true, index: true
    end
  end
end
