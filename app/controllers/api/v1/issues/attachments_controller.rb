class Api::V1::Issues::AttachmentsController < Api::V1::Issues::ApiController
  before_action :set_attachment, only: :destroy

  def create
    authorize @project, :not_viewer?
    attachment = @issue.attachments.new(file: params[:attachment])
    if attachment.save
      render json: attachment.to_json, status: :created
    else
      render json: attachment.errors.to_json, status: :bad_request
    end
  end

  def destroy
    authorize @project, :not_viewer?
    if @attachment.destroy
      render json: @attachment.to_json, status: :ok
    else
      head(:bad_request)
    end
  end

  private

  def set_attachment
    @attachment = @project.issue_attachments.find(params[:id])
  end
end
