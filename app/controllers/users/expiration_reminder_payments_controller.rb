class Users::ExpirationReminderPaymentsController < ApplicationController
  def expired
    return head :forbidden unless current_user.is_payment_expired
    modal_show params: { parent_controller: :pages, parent_url: root_path }
  end

  def expiring
    return head :forbidden unless current_user.is_payment_expiring
    modal_show params: { parent_controller: :pages, parent_url: root_path }
  end
end
