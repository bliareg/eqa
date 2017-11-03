class Projects::SettingsController < Projects::ProjectsController
  before_action :check_permission

  def index
    @notification_status = current_user.notification(@project).turn_on
  end

  def team
    @members = @project.members.without_deleted.includes(:projects, :roles).order(first_name: :asc, last_name: :asc)
  end

  def delete
  end

  private

  def check_permission
    authorize @project, :member?
  end
end
