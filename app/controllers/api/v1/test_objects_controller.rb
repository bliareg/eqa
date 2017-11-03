class Api::V1::TestObjectsController < Api::V1::ApiController
  before_action :set_user_by_token, unless: -> { action_name == 'index' && params[:auth_token].nil? }
  before_action :set_test_object, except: [:index, :create]

  def index
    if current_user.present?
      authorize @project, :member?
      render json: @project.test_objects.to_json
    else
      web_objects = @project.test_objects.where.not(link: nil)
      render json: web_objects.to_json
    end
  end

  def show
    authorize @project, :member?

    render json: @test_object.attributes.except(:deleted_at).merge('url' => @test_object.url)
  end

  def create
    authorize @project, :developer_or_higher_rank?

    test_object = @project.test_objects.new(test_object_params.merge(user_id: current_user.id))

    if test_object.save
      render json: test_object.to_json
    else
      render json: test_object.errors.to_json, status: :bad_request
    end
  end

  def destroy
    authorize @test_object.project, :manager_or_higher_rank?

    if @test_object.destroy
      render json: @test_object.to_json
    else
      render json: { message: 'Something goes wrong' }, status: :bad_request
    end
  end

  private

  def set_test_object
    @test_object = @project.test_objects.find(params[:id])
  end

  def test_object_params
    params.permit(:file, :link)
  end
end
