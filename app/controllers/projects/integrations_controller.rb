class Projects::IntegrationsController < Projects::ProjectsController
  def index
    authorize @project, :member?
  end
end
