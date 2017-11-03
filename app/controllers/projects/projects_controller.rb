class Projects::ProjectsController < ApplicationController
  before_action :set_project
  before_action :set_presenter

  private

  def set_project
    @project = Project.friendly.find(params[:project_id])
  end

  def set_presenter
    @project = ProjectPresenter.present(@project, view_context)
  end
end
