class Api::V1::OrganizationsController < Api::V1::ApiController
  skip_before_action :set_project_by_token
  before_action :set_user_by_token
  before_action :set_organization, except: [:index, :create]

  def index
    render json: current_user.organizations.to_json
  end

  def show
    authorize @organization, :member?

    render json: @organization.to_json
  end

  def create
    return head :forbidden if current_user.is_payment_expired

    organization = Organization.new(organization_params)
    if organization.save
      render json: organization.to_json
    else
      render json: organization.errors.to_json, status: :bad_request
    end
  end

  def update
    authorize @organization, :owner?

    if @organization.update(organization_params)
      render json: @organization.to_json
    else
      render json: @organization.errors.to_json, status: :bad_request
    end
  end

  def destroy
    authorize @organization, :owner?
    if @organization.destroy
      render json: @organization.to_json
    else
      render json: { message: 'Something goes wrong' }, status: :bad_request
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.require(:organization).permit(:title, :description)
  end
end
