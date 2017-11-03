class CreateAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :attachments do |t|
      t.integer :issue_id

      t.timestamps
    end
    add_index :attachments, :issue_id
  end
end
