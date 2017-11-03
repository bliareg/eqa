class Api::V1::TestPlansController < Api::V1::ApiController
  before_action :set_user_by_token
  before_action :set_test_plan, except: [:index, :create]

  def index
    authorize @project, :member?
    render json: @project.test_plans.to_json
  end

  def show
    authorize @project, :member?
    render json: @test_plan.to_json
  end

  def create
    authorize @project, :tester_or_higher_rank?
    test_plan = @project.test_plans.new(test_plan_params.merge(created_by: current_user.id))
    if test_plan.save
      render json: test_plan.to_json
    else
      render json: test_plan.errors.to_json, status: 422
    end
  end

  def update
    authorize @project, :tester_or_higher_rank?
    if @test_plan.update(test_plan_params)
      render json: @test_plan.to_json
    else
      render json: @test_plan.errors.to_json, status: 422
    end
  end

  def destroy
    authorize @project, :tester_or_higher_rank?
    if @test_plan.destroy
      render json: @test_plan.to_json
    else
      render json: { message: 'Something goes wrong' }, status: 422
    end
  end

  private

  def set_test_plan
    @test_plan = @project.test_plans.find(params[:id])
  end

  def test_plan_params
    params.require(:test_plan).permit(:title, :description)
  end
end
