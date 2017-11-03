class MailchimpHelper < IntegrationHelper
  DEFAULT_EMAIL_STATUS='subscribed'.freeze

  def initialize
    set_connection
  end

  def create_user(attributes)
    path = "lists/#{ENV['MAILCHIMP_EASYQA_COMPANY_ID']}/members"
    response = send_request(path, :post) do |req|
      req.body = user_attributes(attributes)
    end
    operation_status(response, response.body)
  end

  def update_user(service_id, attributes)
    path = "lists/#{ENV['MAILCHIMP_EASYQA_COMPANY_ID']}/members/#{service_id}"
    response = send_request(path, :patch) do |req|
      req.body = user_attributes(attributes)
    end
    operation_status(response, response.body)
  end

  def destroy_user(service_id)
    path = "lists/#{ENV['MAILCHIMP_EASYQA_COMPANY_ID']}/members/#{service_id}"
    response = send_request(path, :delete)
    operation_status(response, response.body)
  end

  def show_user(service_id)
    path = "lists/#{ENV['MAILCHIMP_EASYQA_COMPANY_ID']}/members/#{service_id}"
    response = send_request(path, :get)
    operation_status(response, response.body)
  end

  def all_users
    path = "lists/#{ENV['MAILCHIMP_EASYQA_COMPANY_ID']}/members"
    response = send_request(path, :get)
    operation_status(response, response.body)
  end

  private

  def set_connection
    @connection = Faraday.new(url: ENV['MAILCHIMP_URL']) do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
    @connection.basic_auth(ENV['MAILCHIMP_USERNAME'], ENV['MAILCHIMP_PASSWORD'])
  end

  def send_request(url, html_method, &block)
    @connection.send(html_method) do |req|
      req.url url
      req.headers['Content-Type'] = 'application/json'
      yield(req) if block.present?
    end
  end

  def user_attributes(attributes)
    {
      email_address: attributes['email'],
      status: DEFAULT_EMAIL_STATUS,
      merge_fields: {
        FNAME: attributes['first_name'],
        LNAME: attributes['last_name']
      }
    }
  end
end
