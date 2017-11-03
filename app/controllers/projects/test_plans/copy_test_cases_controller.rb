class Projects::TestPlans::CopyTestCasesController < Projects::ProjectsController
  skip_before_action :set_presenter

  def new
    authorize @project, :tester_or_higher_rank?
    @test_plans = @project.test_plans.includes(:test_modules)
  end

  def create
    authorize @project, :tester_or_higher_rank?
    test_cases = @project.test_cases.where(id: params[:test_cases_ids])
    test_modules = @project.test_modules.where(id: params[:test_modules_ids])

    test_modules.each do |test_module|
      test_cases.each do |test_case|
        TestCase.create(
          test_case.attributes.merge(
            id: nil, module_id: test_module.id,
            test_plan_id: test_module.test_plan_id
          )
        )
      end
    end
    redirect_to project_test_plans_path(@project)
  end
end
