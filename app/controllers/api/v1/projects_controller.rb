class Api::V1::ProjectsController < Api::V1::ApiController
  skip_before_action :set_project_by_token
  before_action :set_organization, only: [:create]
  before_action :set_user_by_token
  before_action :set_project, except: [:index, :create]

  def index
    render json: current_user.all_projects.to_json
  end

  def show
    authorize @project, :member?

    render json: @project.to_json
  end

  def create
    authorize @organization, :admin_or_higher_rank?

    project = @organization.projects.new(
      project_params.merge(user_id: current_user.id, token: SecureRandom.urlsafe_base64(24))
    )
    if project.save
      render json: project.to_json
    else
      render json: project.errors.to_json, status: :bad_request
    end
  end

  def update
    authorize @project, :manager_or_higher_rank?

    if @project.update(project_params)
      render json: @project.to_json
    else
      render json: @project.errors.to_json, status: :bad_request
    end
  end

  def destroy
    authorize @project, :manager_or_higher_rank?
    if @project.destroy
      render json: @project.to_json
    else
      render json: { message: 'Something goes wrong' }, status: :bad_request
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title)
  end
end
