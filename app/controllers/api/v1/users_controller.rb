class Api::V1::UsersController < Api::V1::ApiController
  before_action :set_user_by_token, only: [:sign_out, :organization_members]
  skip_before_action :set_project_by_token, except: :project_members_list

  def project_members_list
    render json: {
      users: @project.members_data_with_key(:email)
    }
  end

  def organization_members
    organization = if params[:organization_title]
                     Organization.find_by_title(params[:organization_title])
                   else
                     Organization.find_by_id(params[:organization_id])
                   end

    if organization
      authorize organization, :member?

      render json: organization.members
    else
      render json: { message: 'Organization not found' }, status: :not_found
    end
  end

  def show
    user = params[:email] ? User.find_by_email(params[:email]) : User.find_by_id(params[:id])

    if user
      render json: user
    else
      render json: { message: 'User not found' }, status: :not_found
    end
  end

  def sign_in
    user = User.find_by_email(user_login_params[:email])
    if user && user.valid_password?(user_login_params[:password])
      render json: { auth_token: create_token(user), name: user.name }
    else
      render json: { message: 'Invalid email or password' }, status: 404
    end
  end

  def sign_out
    if @current_user.authenticity_tokens.find_by_token(params[:auth_token]).destroy
      render json: { message: 'Success' }
    else
      render json: { message: 'Something went wrong' }, status: 500
    end
  end

  private

  def create_token(user)
    auth_token = user.authenticity_tokens.create(token: SecureRandom.urlsafe_base64(48))
    auth_token.token
  end

  def user_login_params
    params.require(:user).permit(:email, :password)
  end
end
