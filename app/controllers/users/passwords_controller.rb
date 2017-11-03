class Users::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
   def new    
    super
   end

  # POST /resource/password
  def create
    @user = User.find_by_email(params['user']['email'])
    if @user
      if @user.deleted_at.nil? 
        super   
      elsif @user.locked_at
        modal_show partial: 'users/sessions/account_is_locked', params: {
          parent_action_name: :new
        }
      else
        modal_show partial: 'users/sessions/activate_account', params: {
          parent_action_name: :new
        }
      end
    else  
      super
    end
  end
    
  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    $resource = User.find(params['format'])
    if $resource.reset_password_token.nil?
      redirect_to new_password_path($resource) 
    else
      self.resource = resource_class.new
      resource.reset_password_token = params[:reset_password_token]
    end
  end

  # PUT /resource/password
  def update
    self.resource = $resource
    yield resource if block_given?
    unless resource.nil?
      if resource.errors.empty?
        resource.unlock_access! if unlockable?(resource)

        if Devise.sign_in_after_reset_password
          flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
          set_flash_message!(:notice, flash_message)
          resource.password = params['user']['password']
          resource.save

          if resource.confirmed_at?
            respond_with resource, location: after_resetting_password_path_for(resource)
          else
            uri = confirmation_url(resource, confirmation_token: resource.confirmation_token)
            redirect_to uri
            Devise.sign_in_after_reset_password ? after_sign_in_path_for(resource) : new_session_path(resource_name)
          end
        else
          set_flash_message!(:notice, :updated_not_active)
        end       
      else
        set_minimum_password_length
        respond_with resource
      end
    end
  end

  protected

  def after_resetting_password_path_for(resource)
   super(resource)   
  end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
