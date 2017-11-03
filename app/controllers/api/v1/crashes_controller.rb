class Api::V1::CrashesController < Api::V1::ApiController
  before_action :set_build_by_identeficator
  before_action :initialize_crash

  def upload_crashes
    params[:message] ? create_log_file_for_web_crash : initialize_logfile
    render json: { message: t('success') }
  end

  private

  def initialize_logfile
    array_logs = params['crashesData'] || []
    array_logs.each do |log|
      LogFile.create(crash:                  @crash,
                     log_created_at:         get_datetime(log['createdAt']),
                     crash_log:              get_log_file(log['logFile']),
                     crash_log_file_name:    log['fileName'],
                     crash_log_content_type: 'text/plain')
    end
  end

  def create_log_file_for_web_crash
    crash_log = StringIO.new(Base64.decode64(params[:message]))
    @crash.log_files.create(
      crash_log:              crash_log,
      crash_log_file_name:    "web_crash#{Time.now.to_i}.txt",
      crash_log_content_type: 'text/plain'
    )
  end

  def get_datetime(time_in_ms)
    DateTime.strptime(time_in_ms.to_s, '%Q')
  end

  def get_log_file(file)
    StringIO.new(ActiveSupport::Gzip.decompress(Base64.decode64(file)))
  end
end
