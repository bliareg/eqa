class Api::V1::TestPlans::TestModules::ApiController < Api::V1::ApiController
  before_action :set_user_by_token
  before_action :set_test_module, only: [:index, :create]

  private

  def set_test_module
    @test_module = TestModule.find_by_id(params[:test_module_id])
  end
end
