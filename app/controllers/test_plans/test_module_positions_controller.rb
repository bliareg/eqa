class TestPlans::TestModulePositionsController < TestPlans::ApplicationController
  before_action :set_test_plan

  def update
    authorize @test_plan.project, :not_viewer?
    current_module = @test_plan.test_modules.find(params[:id])

    if params[:parent_id].present?
      parent_module = @test_plan.test_modules.find(params[:parent_id])
      current_module.move_to_child_of(parent_module)

      parent_module.children.each do |test_module|
        test_module.update_attribute(:position, test_modules_params[test_module.id.to_s].to_i)
      end
    else
      current_module.move_to_root

      @test_plan.roots_test_modules.each do |test_module|
        test_module.update_attribute(:position, test_modules_params[test_module.id.to_s].to_i)
      end
    end
    head :ok
  end

  private

  def test_modules_params
    @modules_positions_params ||= params.require(:positions).permit!
  end
end
