class TestModules::TestCasesPositionsController < ApplicationController
  before_action :set_test_module

  def update
    authorize @test_module.project, :not_viewer?
    @test_module.test_cases.each do |test_case|
      test_case.update_attribute(:position, test_cases_params[test_case.id.to_s].to_i)
    end
    head :ok
  end

  private

  def set_test_module
    @test_module = TestModule.find(params[:id])
  end

  def test_cases_params
    @cases_params ||= params.require(:test_cases_positions).permit!
  end
end
