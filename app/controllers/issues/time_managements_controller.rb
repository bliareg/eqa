class Issues::TimeManagementsController < ApplicationController
  before_action :set_time_management, except: :create

  def create
    @time_management = TimeManagement.new(time_managements_params)
    authorize @time_management.issue.project, :not_viewer?
    render json: { errors: @time_management.errors }, status: :unprocessable_entity unless @time_management.save
  end

  def update
    authorize @time_management
    render json: { errors: @time_management.errors }, status: :unprocessable_entity unless @time_management.update(time_managements_params)
  end

  def destroy
    authorize @time_management
    head(422) unless @time_management.destroy
  end

  private

  def set_time_management
    @time_management = TimeManagement.find(params[:id])
  end

  def time_managements_params
    params.require(:time_management).permit(:spent_time,
                                            :comment,
                                            :user_id,
                                            :issue_id)
  end
end
