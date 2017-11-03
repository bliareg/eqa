module Notificable
  def self.included(base)
    base.after_commit :after_create_notifications, on: :create
    base.after_update :after_update_notifications
    base.before_destroy :before_destroy_notifications
  end

  private

  def after_create_notifications
    send_notifications('new', assigner) if assigner
  end

  def after_update_notifications
    old_values = retrieve_changes
    if assigner_id_changed?
      send_notifications('update', User.find_by_id(assigner_id_was), old_values)
      send_notifications('new', assigner) if assigner
    elsif assigner
      send_notifications('update', assigner, old_values)
    end
    send_notifications('update', reporter, old_values) if reporter_and_reporter_not_assigner
  end

  def before_destroy_notifications
    send_notifications('destroy', assigner) if assigner
    send_notifications('destroy', reporter) if reporter_and_reporter_not_assigner
    notification.try(:really_destroy!) if instance_of? TestRun
  end

  def reporter_and_reporter_not_assigner
    reporter_id && reporter_id != assigner_id
  end

  def retrieve_changes
    old_values_hash.each_with_object([]) do |(attr_name, old_value), changes|
      changes << {
        name: attr_name.sub('_id', '').capitalize,
        old_value: old_value,
        new_value: send(attr_name.sub('_id', ''))
      }
    end
  end
end
