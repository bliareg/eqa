class Api::V1::TestRuns::ApiController < Api::V1::ApiController
  before_action :set_user_by_token
  before_action :set_test_run, only: [:index, :create]

  private

  def set_test_run
    @test_run = TestRun.find_by_id(params[:test_run_id])
  end
end
