class TestRuns::TestRunResultPositionsController < TestRuns::ApplicationsController
  def update
    authorize @test_run.project, :not_viewer?
    @test_run.test_run_results.each do |result|
      result.update_attribute(:position, test_run_result_params[result.id.to_s].to_i)
    end
    head :ok
  end

  private

  def test_run_result_params
    @results_params ||= params.require(:test_run_result_positions).permit!
  end
end
