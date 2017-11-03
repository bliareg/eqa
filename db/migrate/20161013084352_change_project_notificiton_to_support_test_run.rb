class ChangeProjectNotificitonToSupportTestRun < ActiveRecord::Migration[5.0]
  def change
    rename_table :project_notifications, :notifications
    remove_reference :notifications,:project,index: true
    add_reference :notifications, :notificable, polymorphic: true,index: true;
    add_reference :notifications,:parent_notification,index: true
  end
end
