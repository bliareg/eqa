class Projects::TestActivitiesController < Projects::ProjectsController
  layout 'test_activities'

  def index
    authorize @project, :member?
    gon.test_order = TestCase.line_chart(day_ago: 14, parent: @project, field: :case_type)
    gon.test_results = TestRunResult.line_chart(day_ago: 14, parent: @project, field: :status)
    @test_run_info = @project.test_runs.last
  end
end
