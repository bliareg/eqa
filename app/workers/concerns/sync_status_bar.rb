module SyncStatusBar
  protected

  def status_bar_progress(percent, message)
    at(status_container.at + percent, message)
  end

  def init_progress_step(array, max_progress)
    @progress_step = max_progress / array.length unless array.length.zero?
    @progress_value = 0
  end

  def set_progress_step(plugin_name, message)
    @progress_value += @progress_step
    rounded_progress = @progress_value.round
    return if rounded_progress < 1

    status_bar_progress(rounded_progress, "#{plugin_name}: #{message}")
    @progress_value -= rounded_progress
  end

  def append_to_payload(status, plugin_name, message = '')
    payload_obj = status_container.payload

    count = payload_obj.values
                       .flatten
                       .select { |name| name =~ Regexp.new(plugin_name) }
                       .size + 1
    payload_obj[status] << "#{plugin_name} #{count} #{payload_message(status)}#{message}"
    self.payload = payload_obj
  end

  private

  def payload_message(status)
    status == 'fail' ? I18n.t('is_failed') : I18n.t('is_synchronized')
  end
end
