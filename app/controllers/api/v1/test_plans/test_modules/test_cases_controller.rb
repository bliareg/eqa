class Api::V1::TestPlans::TestModules::TestCasesController < Api::V1::TestPlans::TestModules::ApiController
  skip_before_action :set_test_module, only: :index
  before_action :set_test_case, except: [:index, :create]
  ALLOWED_INDEX_PARENTS = { test_module: :test_modules, test_plan: :test_plans }.freeze

  def index
    authorize @project, :member?
    parent = @project.public_send(ALLOWED_INDEX_PARENTS[params[:parent_name].to_sym]).find(params[:parent_id])
    render json: parent.test_cases.to_json
  end

  def show
    authorize @project, :member?

    render json: @test_case.to_json
  end

  def create
    authorize @project, :tester_or_higher_rank?
    test_case = @test_module.test_cases.new(
      test_case_params.merge(created_by: current_user.id, test_plan_id: @test_module.test_plan_id)
    )
    if test_case.save
      render json: test_case.to_json
    else
      render json: test_case.errors.to_json, status: 422
    end
  end

  def update
    authorize @project, :tester_or_higher_rank?
    if @test_case.update(test_case_params.merge(updated_by: current_user.id))
      render json: @test_case.to_json
    else
      render json: @test_case.errors.to_json, status: 422
    end
  end

  def destroy
    authorize @project, :tester_or_higher_rank?
    if @test_case.destroy
      render json: @test_case.to_json
    else
      render json: { message: 'Something goes wrong' }, status: 422
    end
  end

  private

  def set_test_case
    @test_case = @project.test_cases.find(params[:id])
  end

  def test_case_params
    params.require(:test_case).permit(:title, :pre_steps, :steps, :expected_result, :case_type)
  end
end
