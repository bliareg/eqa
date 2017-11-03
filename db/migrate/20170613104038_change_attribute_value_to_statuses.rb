class ChangeAttributeValueToStatuses < ActiveRecord::Migration[5.0]
  def up
    status = Status.find_by(id: Status::DEFAULT_STATUSES[:submitted][:id])
    status.update_attribute(:name, 'Submitted') if status
  end

  def down
    status = Status.find_by(id: Status::DEFAULT_STATUSES[:submitted][:id])
    status.update_attribute(:name, 'Submited') if status
  end
end
