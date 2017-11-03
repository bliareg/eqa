module LicenseExpirable
  extend ActiveSupport::Concern

  def authorize_license!
    if !current_license&.authorized?
      install_expired
      update_payment_notification_status(:expired)
    elsif !current_license.valid_team_size?
      install_expired
      update_payment_notification_status(:invalid_team_count)
    end
  end

  def check_expiring!
    update_payment_notification_status(:expiring) if current_license&.expiring?
  end

  def install_expired
    organizations.each { |o| o.update_attribute(:is_payment_expired, true) }
    projects.update_all(deleted_at: Time.now, is_payment_expired: true)
  end

  def remove_expired
    update(is_payment_expired: false, is_payment_expiring: false, payment_notification_visible: false)
    expired_owned_organizations.each { |o| o.update_attribute(:is_payment_expired, false) }
    Project.restore(expired_projects.ids, EasyQA::Constants::Restore::PARAMS)
  end

  def check_team_size_block!
    remove_expired if current_license&.valid_team_size?
  end

  def expire_projects_on_delete?
    current_license&.invalid_team_count? || !current_license&.authorized?
  end

  def update_payment_notification_status(action)
    update_params = case action
                    when :expired
                      { payment_notification_visible: true, is_payment_expired: true, is_payment_expiring: false }
                    when :expiring
                      { payment_notification_visible: true, is_payment_expiring: true, is_payment_expired: false }
                    when :invalid_team_count
                      { payment_notification_visible: true, is_payment_expiring: false, is_payment_expired: false }
                    end || {}
    update_attributes(update_params)
  end
end
