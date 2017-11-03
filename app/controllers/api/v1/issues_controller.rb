class Api::V1::IssuesController < Api::V1::ApiController
  before_action :set_user_by_token,
                if: -> { action_name.in?(['issue_info', 'create']) ? params[:auth_token].present? : true }
  before_action :set_build_by_identeficator, only: :issue_info
  before_action :initialize_crash, only: :create, if: proc { send_from_devise? }
  before_action :set_issue, except: [:issue_info, :create, :index]

  def issue_info
    authorize @project, :member? if current_user.present?
    render json: {
      test_object_id: @build.id,
      issue_type: Issue.hash_by_options(:issue_type),
      priority: Issue.hash_by_options(:priority),
      users: @project.members_data_with_key(:id)
    }.to_json
  end

  def create
    authorize @project, :member? if current_user.present?
    issue = Issue.new(issue_params.merge(project_id: @project.id,
                                         crash_id: @crash.try(:id),
                                         reporter_id: current_user.try(:id)))
    build_files(issue)
    if issue.save
      render json: issue.to_json
    else
      render json: { message: issue.errors.messages }, status: 422
    end
  end

  def index
    authorize @project, :member?
    render json: @project.issues.to_json
  end

  def show
    authorize @project, :member?
    render json: @issue.to_json
  end

  def update
    authorize @project, :not_viewer?
    @issue.assign_attributes(issue_params)
    build_files(@issue)
    if @issue.save
      render(json: @issue.to_json)
    else
      render(json: @issue.errors.to_json)
    end
  end

  def destroy
    authorize @project, :not_viewer?
    if @issue.destroy
      render json: @issue.to_json
    else
      render json: { message: 'Something goes wrong' }, status: 422
    end
  end

  private

  def issue_params
    params.permit(:summary,
                  :description,
                  :issue_type,
                  :priority,
                  :assigner_id,
                  :status_id,
                  :test_object_id)
  end

  def build_files(issue)
    params.each do |key, value|
      issue.attachments.build(file: value) if key =~ /\.['jpg' | 'mp4']/
    end
  end

  def send_from_devise?
    params[:deviseSerial].present? && params[:deviseModel].present? \
      && params[:osVersion].present? && params[:test_object_id].present?
  end

  def set_issue
    id_in_project = params[:id][/(?<=pid)\d+/]
    @issue = @project.issues.public_send(
      id_in_project ? 'find_by_project_issue_number' : 'find', id_in_project || params[:id]
    )
  end
end
