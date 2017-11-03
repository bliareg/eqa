class Api::V1::ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  before_action :set_project_by_token
  respond_to :json

  private

  def set_project_by_token
    @project = Project.find_by_token(params[:token])
    return render json: { message: t('bad_token') },
                  status: 404 if @project.nil?
  end

  def set_build_by_identeficator
    @build = if params[:link].present?
               @project.test_objects.find_by(link: params[:link])
             else
               @project.test_objects.find_by(identeficator: identeficator)
             end
    return render json: { message: 'build not found' },
                  status: 404 if @build.nil?
  end

  def identeficator
    "#{params['packageName']}:#{params['buildVersionCode']}:#{params['buildVersionName']}"
  end

  def set_user_by_token
    @current_user = User.joins(:authenticity_tokens)
                        .find_by(authenticity_tokens: { token: params[:auth_token] })
    return render json: { message: 'User not found' }, status: 404 if @current_user.nil?

    set_current_user_id
  end

  def initialize_crash
    @crash = crash_by_build || new_crash_instance
    render json: { message: @crash.errors.messages },
           status: 422 unless @crash.save
  end

  def crash_by_build
    Crash.find_by(test_object_id: params[:test_object_id] || @build.id,
                  device_serial:  params['deviceSerial'])
  end

  def new_crash_instance
    Crash.new(test_object_id:      params[:test_object_id] || @build.id,
              os_version:          params['osVersion'],
              device:              params['device'],
              device_model:        params['deviceModel'],
              device_brand:        params['deviceBrand'],
              device_manufacturer: params['deviceManufacturer'],
              device_serial:       params['deviceSerial'])
  end
end
