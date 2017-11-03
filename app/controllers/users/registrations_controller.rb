class Users::RegistrationsController < Devise::RegistrationsController
  def referral_invitation
    cookies[:referral_token] = params[:referral_token]
    redirect_to new_user_registration_path
  end

  def create
    if cookies[:referral_token]
      user = User.find_by(referral_token: cookies[:referral_token])
      params[:user][:referred_by] = user.id if user
    end
    build_resource(sign_up_params)
    raw_token, hashed_token = Devise.token_generator.generate(resource.class, :reset_password_token)
    resource.reset_password_token = raw_token
    resource.save
    yield resource if block_given?
    
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  private

  def after_inactive_sign_up_path_for(resource)
    confirmation_instruction_path(email: params[:user][:email])
  end
end
