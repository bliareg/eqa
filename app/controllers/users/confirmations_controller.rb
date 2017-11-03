class Users::ConfirmationsController < Devise::ConfirmationsController
  def unconfirmed
    user = User.find_by(email: params[:email])
    if user && user.confirmed_at.nil?      
      render 'unconfirmed.js.erb'
    end  
  end

  def create
    raw_token, hashed_token = Devise.token_generator.generate(resource.class, :reset_password_token)
    resource.reset_password_token = hashed_token
    resource.reset_password_sent_at = Time.now.utc
    resource.save(validate: false)
    self.resource = resource_class.send_confirmation_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      respond_with({}, location: after_resending_confirmation_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  def resend_unconfirmed
    user = User.find_by(email: params[:email])
    if user && user.confirmed_at.nil?
      render 'unconfirmed.js.erb'
    end
  end

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message!(:notice, :confirmed)
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
    end
  end

  def resend
    user = User.find_by(email: params[:email])     
    user.send_confirmation_instructions if user      
  end

  def instruction
  end

  private

  def after_confirmation_path_for(_resource_name, resource)   
   resource.statistics.create
   sign_in resource
   root_path
  end
end
