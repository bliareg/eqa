class Api::V1::StatusesController < Api::V1::ApiController
  before_action :set_user_by_token
  before_action :set_status, except: [:index, :create]

  def index
    authorize @project, :member?
    render json: @project.statuses.to_json
  end

  def show
    authorize @project, :member?
    render json: @status.to_json
  end

  def create
    authorize @project, :not_viewer?
    status = @project.statuses.new(status_params)
    if status.save
      status.project_statuses.create(project_id: @project.id)
      render json: status.to_json
    else
      render json: status.errors.to_json, status: :bad_request
    end
  end

  def update
    authorize @project, :not_viewer?
    if @status.update(status_params)
      render json: @status.to_json
    else
      render json: @status.errors.to_json, status: :bad_request
    end
  end

  def destroy
    authorize @project, :not_viewer?
    if @status.destroy
      render json: @status.to_json
    else
      render json: { message: 'Something goes wrong' }, status: :bad_request
    end
  end

  private

  def set_status
    @status = @project.statuses.find(params[:id])
  end

  def status_params
    params.require(:status_object).permit(:name)
  end
end
