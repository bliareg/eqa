class TestPlans::ApplicationController < ApplicationController
  before_action :set_test_plan, only: [:index, :create]

  private

  def set_test_plan
    @test_plan = TestPlan.find(params[:test_plan_id])
  end
end
