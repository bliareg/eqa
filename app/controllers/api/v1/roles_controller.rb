class Api::V1::RolesController < Api::V1::ApiController
  before_action :set_user_by_token
  skip_before_action :set_project_by_token, if: -> { params[:token].nil? }
  before_action :set_organization, only: [:index, :create]
  before_action :set_role, except: [:index, :create]

  def index
    authorize @organization, :member?
    render json: @project.present? ? @project.roles : @organization.member_roles
  end

  def show
    authorize @role.organization, :member?
    render json: @role.to_json
  end

  def create
    authorize @organization, :admin_or_higher_rank?

    role = @organization.roles.new(role_create_params)
    if role.api_permitted? && role.save
      render json: role.to_json
    else
      render json: { message: 'Not permitted' }, status: :bad_request
    end
  end

  def update
    authorize @role.organization, :admin_or_higher_rank?

    @role.assign_attributes(role_update_params)
    if @role.api_permitted? && @role.save
      render json: @role.to_json
    else
      render json: { message: 'Not permitted' }, status: :bad_request
    end
  end

  def destroy
    authorize @role.organization, :admin_or_higher_rank?

    if @role.api_permitted? && @role.destroy
      render json: @role.to_json
    else
      render json: { message: 'Something goes wrong' }, status: :bad_request
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def role_create_params
    attrs = params.permit(:role, :user_id, :email)
    attrs[:user_id] = User.find_by_email(attrs.delete(:email)).id if attrs[:email]
    @project.present? ? attrs.merge(project_id: @project.id) : attrs
  end

  def role_update_params
    params.permit(:role)
  end

  def set_role
    @role = Role.find(params[:id])
  end
end
