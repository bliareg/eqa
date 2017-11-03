class Projects::TestObjectsController < Projects::ProjectsController
  include ProjectOverviewsHelper

  skip_before_action :set_project, only: [:show, :destroy]
  skip_before_action :set_presenter, except: [:index, :create]
  before_action :set_test_object, only: [:show, :destroy]
  layout 'projects/projects'

  def index
    authorize @project, :member?
  end

  def new
    authorize @project, :developer_or_higher_rank?
    @test_object = TestObject.new
    params[:page] = 'test_objects' if request.format.symbol == :html
    modal_show
  end

  def create
    authorize @project, :developer_or_higher_rank?
    @test_object = TestObject.new(test_object_params)
    @test_object.save
    @response = generate_response
    respond_to do |format|
      format.json { render json: @response }
      format.js {}
    end
  end

  def show
    project = @test_object.project
    authorize project, :member?
    modal_show params: {
      parent_action_name: :index,
      project_id: project.slug,
      parent_url: project_test_objects_path(project.slug)
    }
  end

  def destroy
    authorize @test_object.project, :manager_or_higher_rank?
    @test_object.plugin.present? ? @test_object.destroy : @test_object.really_destroy!
  end

  private

  def set_project
    @project = Project.friendly.find(params[:project_id])
  end

  def set_project_presenter
    @project = ProjectPresenter.present(@project, view_context)
  end

  def set_test_object
    @test_object = TestObject.find(params[:id])
  end

  def test_object_params
    params.require(:test_object).permit(:file, :link, :platform_version)
          .merge(user_id: current_user.id, project_id: @project.id)
  end

  def generate_response
    {
      after_upload_html: render_to_string(partial: 'after_upload',
                                          formats: [:html]),
      html: html_string,
      project_id: @project.id
    }
  end

  def html_string
    case params[:page]
    when 'projects'
      render_to_string(partial: 'projects/project_counters',
                       locals:  { project: @project },
                       formats: [:html])
    when 'test_objects'
      render_to_string(file: 'projects/test_objects/index.html.erb',
                       layout: false)
    else
      get_diagram_data
      render_to_string(file: 'projects/show.html.erb', layout: false)
    end
  end
end
