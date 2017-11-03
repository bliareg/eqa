class Api::V1::TestPlans::ApiController < Api::V1::ApiController
  before_action :set_user_by_token
  before_action :set_test_plan, only: [:index, :create]

  private

  def set_test_plan
    @test_plan = TestPlan.find_by_id(params[:test_plan_id])
  end
end
