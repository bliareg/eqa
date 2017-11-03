class Api::V1::Issues::ApiController < Api::V1::ApiController
  before_action :set_user_by_token
  before_action :set_issue, only: :create

  private

  def set_issue
    id_in_project = params[:issue_id][/(?<=pid)\d+/]
    @issue = @project.issues.public_send(
      id_in_project ? 'find_by_project_issue_number' : 'find', id_in_project || params[:issue_id]
    )
  end
end
