class Api::V1::TestRuns::TestRunResultsController < Api::V1::TestRuns::ApiController
  before_action :set_test_run_result, except: [:index]

  def index
    authorize @project, :member?

    render json: @test_run.test_run_results.to_json
  end

  def show
    authorize @project, :member?

    render json: @test_run_result.to_json
  end

  def update
    authorize @project, :tester_or_higher_rank?
    if @test_run_result.update(test_run_result_params)
      render json: @test_run_result.to_json
    else
      render json: @test_run_result.errors.to_json, status: 422
    end
  end

  def destroy
    authorize @project, :tester_or_higher_rank?
    if @test_run_result.destroy
      render json: @test_run_result.to_json
    else
      render json: { message: 'Something goes wrong' }, status: 422
    end
  end

  private

  def set_test_run_result
    @test_run_result = @project.test_run_results.find(params[:id])
  end

  def test_run_result_params
    attrs = params.require(:test_run_result).permit(:result_status, :test_case_id)
    attrs[:status] = attrs.delete(:result_status)
    attrs[:status] != TestRunResult::UNTESTED ? attrs.merge(passed_by: current_user.id) : attrs
  end
end
