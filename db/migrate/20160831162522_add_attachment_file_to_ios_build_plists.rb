class AddAttachmentFileToIosBuildPlists < ActiveRecord::Migration
  def self.up
    change_table :ios_build_plists do |t|
      t.attachment :file
    end
  end

  def self.down
    remove_attachment :ios_build_plists, :file
  end
end
