class Api::V1::TestPlans::TestModulesController < Api::V1::TestPlans::ApiController
  before_action :set_test_module, except: [:index, :create]

  def index
    authorize @project, :member?

    render json: @test_plan.test_modules.to_json
  end

  def show
    authorize @project, :member?

    render json: @test_module.to_json
  end

  def create
    authorize @project, :tester_or_higher_rank?
    test_module = @test_plan.test_modules.new(test_module_params.merge(created_by: current_user.id))
    if test_module.save
      render json: test_module.to_json
    else
      render json: test_module.errors.to_json, status: 422
    end
  end

  def update
    authorize @project, :tester_or_higher_rank?
    if @test_module.update(test_module_params)
      render json: @test_module.to_json
    else
      render json: @test_module.errors.to_json, status: 422
    end
  end

  def destroy
    authorize @project, :tester_or_higher_rank?
    if @test_module.destroy
      render json: @test_module.to_json
    else
      render json: { message: 'Something goes wrong' }, status: 422
    end
  end

  private

  def set_test_module
    @test_module = @project.test_modules.find_by_id(params[:id])
  end

  def test_module_params
    params.require(:test_module).permit(:title, :description, :parent_id)
  end
end
