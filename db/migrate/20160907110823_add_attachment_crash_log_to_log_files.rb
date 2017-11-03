class AddAttachmentCrashLogToLogFiles < ActiveRecord::Migration
  def self.up
    change_table :log_files do |t|
      t.attachment :crash_log
    end
  end

  def self.down
    remove_attachment :log_files, :crash_log
  end
end
