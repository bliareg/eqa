module PaymentExpirable
  extend ActiveSupport::Concern

  if Rails.env.development? || Rails.env.staging?
    TRIAL_PERIOD = 29.day.freeze
    START_TRIAL_PERIOD = Time.now
  else
    TRIAL_PERIOD = 29.days.freeze # 30 dayif if count today
    START_TRIAL_PERIOD = Time.now # DateTime.new(2017, 3, 13).freeze
  end
  NOTIFICATION_DAYS = [1, 2, 3, 4, 5, 6, 7, 14].freeze
  EXPERATION_REMAINING = 14.days.freeze

  included do
    scope :with_marked_payment_expired,     -> { where(is_payment_expired: true) }
    scope :without_marked_payment_expired,  -> { where(is_payment_expired: false) }
    scope :with_marked_payment_expiring,    -> { where(is_payment_expiring: true) }
    scope :without_marked_payment_expiring, -> { where(is_payment_expiring: false) }
    scope :with_payment_expired,
          -> { joins(:billing).where('billings.expired_at IS NOT NULL AND billings.expired_at <= ?', DateTime.now) }
    scope :with_payment_expiring,
          -> { joins(:billing).where(billings: { expired_at: DateTime.now..EXPERATION_REMAINING.from_now }) }
  end

  class_methods do
    def update_expirations!
      all.includes(:billing, :organization_owner_roles).each(&:install_expired_at!)
    end

    def check_payments!
      isntall_users_payment_expired!
      install_organizations_payment_expiring!
    end

    def check_payments_notifications!
      with_marked_payment_expired.or(with_marked_payment_expiring).each do |user|
        next if user.billing.nil?
        time_difference = user.billing.expires_in
        if time_difference == 3
          PaymentMailer.send_a_reminder_email(user.id).deliver_later
        end 
        user.update_attribute(:payment_notification_visible, true) if time_difference.in?(NOTIFICATION_DAYS) || time_difference <= 0
      end
    end

    private

    def isntall_users_payment_expired!
      without_marked_payment_expired.with_payment_expired.each do |user|
        user.update(is_payment_expired: true, is_payment_expiring: false)
        # user.owned_organizations.each(&:destroy)
        user.owned_organizations.each { |o| o.update_attribute(:is_payment_expired, true) }
        user.projects.each(&:destroy)
        # user.hired_admins.each { |admin| admin.update(is_payment_expiring: false) } 
      end
    end

    def install_organizations_payment_expiring!
      without_marked_payment_expiring.with_payment_expiring.each do |user|
        user.update(is_payment_expiring: true)
        # user.hired_admins.without_marked_payment_expiring
            # .each { |admin| admin.update(is_payment_expiring: true) }
        user.owned_organizations.each { |org| org.update(is_payment_expiring: true) }
      end
    end
  end

  def install_expired_at!(first_owner_role_created_at = organization_owner_roles.first_created_at)
    return if first_owner_role_created_at.nil?
    billing.update_attribute(
      :expired_at, ([first_owner_role_created_at, START_TRIAL_PERIOD].max + TRIAL_PERIOD).end_of_day
    )
  end
end
