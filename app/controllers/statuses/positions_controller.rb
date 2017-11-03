module Statuses
  class PositionsController < StatusesController
    skip_before_action :set_status

    def update
      position_params.each do |status_id, position|
        project_status = ProjectStatus.find_by(status_id: status_id,
                                               project_id: @project.id)
        project_status.update(position: position) if project_status
      end
      head :ok
    end

    private

    def position_params
      params.require(:positions).permit!
    end
  end
end
