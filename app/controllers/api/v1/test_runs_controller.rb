class Api::V1::TestRunsController < Api::V1::ApiController
  before_action :set_user_by_token
  before_action :set_test_run, except: [:index, :create]

  def index
    authorize @project, :member?

    render json: @project.test_runs.to_json
  end

  def show
    authorize @project, :member?

    render json: @test_run.to_json
  end

  def create
    authorize @project, :tester_or_higher_rank?

    test_run = @project.test_runs.joins(:test_run_results).new(
      test_run_params.merge(reporter_id: current_user.id)
    )
    if test_run.save
      render json: test_run.to_json
    else
      render json: test_run.errors.to_json, status: :bad_request
    end
  end

  def update
    authorize @project, :tester_or_higher_rank?

    if @test_run.update(test_run_params)
      render json: @test_run.to_json
    else
      render json: @test_run.errors.to_json, status: :bad_request
    end
  end

  def destroy
    authorize @project, :tester_or_higher_rank?
    if @test_run.destroy
      render json: @test_run.to_json
    else
      render json: { message: 'Something goes wrong' }, status: :bad_request
    end
  end

  private

  def set_test_run
    @test_run = @project.test_runs.find(params[:id])
  end

  def test_run_params
    params.require(:test_run).permit(
      :title, :description, :project_id, :assigner_id, :test_cases,
      test_run_results_attributes: [
        :test_case_id, :id, :_destroy, :test_plan_id
      ]
    )
  end
end
