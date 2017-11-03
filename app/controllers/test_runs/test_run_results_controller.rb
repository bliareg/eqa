class TestRuns::TestRunResultsController < TestRuns::ApplicationsController
  before_action :set_test_run_result

  def show
    authorize @test_run_result.project, :tester_or_higher_rank?
    @result_index = @test_run.test_results_sorted_array(@column_visibility).index(@test_run_result)

    modal_show params: {
      parent_controller: :test_runs,
      parent_url: test_run_path(@test_run_result.test_run_id),
      id: @test_run_result.test_run_id
    }
  end

  def destroy
    return unless @test_run.test_results_sorted_array(@column_visibility).length > 1
    authorize @test_run_result.project, :tester_or_higher_rank?
    @test_run_result.destroy
    head :ok
  end

  private

  def set_test_run_result
    @test_run_result = TestRunResult.find(params[:id])
    @test_run = @test_run_result.test_run
    @column_visibility = @test_run.column_visibility(current_user)
  end
end
