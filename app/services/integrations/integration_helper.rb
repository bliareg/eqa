require 'faraday_middleware'

class IntegrationHelper
  def initialize(arguments)
    allowed_methods = retrive_allowed_methods
    arguments.each do |key, value|
      method_name = (key.to_s + '=').to_sym
      send(method_name, value) if method_name.in?(allowed_methods)
    end
  end

  protected

  def operation_status(response, body = nil)
    message = response.body['message'] \
              || response.body['error'] if response.body.present?
    complete = message.nil? && \
               /^2\d{2}$/ === (response.try(:status).to_s || response.try(:code))
    message = 'Success' if complete
    {
      complete: complete,
      message:  message,
      body:     body || response.body
    }
  end

  private

  def retrive_allowed_methods
    public_methods.select { |method_name| method_name =~ /[a-z]=$/ }
  end
end
