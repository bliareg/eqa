class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: [:create]
# before_action :configure_sign_in_params, only: [:create]
  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    if current_user.nil?
      user = User.find_by_email(params['user']['email']) 
        if user && user.confirmed_at.nil?
          params[:email] = user.email
          render 'users/confirmations/unconfirmed.js.erb'
        end
      flash[:error] = t('devise.failure.invalid', authentication_keys: 'Email')
    elsif current_user.deleted_at.present? || current_user.locked_at.present?
      @user = current_user
      sign_out current_user
      request.env['devise.allow_params_authentication'] = false
    else
      super
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
