module Statuses
  class ProjectStatusesController < StatusesController
    skip_before_action :set_status
    before_action :set_project_status, only: :update

    def update
      return head(422) unless @project_status.update(project_status_params)
      head :ok
    end

    private

    def set_project_status
      @project_status = ProjectStatus.find(params[:id])
    end

    def project_status_params
      params.require(:project_status).permit(:color, :position, :show)
    end
  end
end
