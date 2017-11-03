class Projects::TestObjects::MailersController < ApplicationController
  before_action :set_test_object, except: :show
  skip_before_action :authenticate_user!, only: :show

  def new
    @project = @test_object.project
    authorize @project, :member?
    @members = @project.members
    modal_show params: {
      parent_controller: 'Projects::TestObjects',
      project_id: @project.slug,
      parent_url: project_test_objects_path(@project.slug)
    }
  end

  def create
    return head :unprocessable_entity if params[:emails].nil?

    params[:emails].each do |email|
      UserMailer.link_to_build_mail(@test_object.id, email).deliver_later
    end
    head :ok
  end

  def show
    test_object = TestObject.find(params[:id])
    render html: view_context.link_to('Install', test_object.url)
  end

  private

  def set_test_object
    @test_object = TestObject.find(params[:test_object_id])
  end
end
