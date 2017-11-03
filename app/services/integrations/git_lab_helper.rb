class GitLabHelper < IntegrationHelper
  include MobileBuilder

  attr_accessor :base_url, :access_token, :service_project_id,
                :project_url, :username, :branch

  API_PATH = '/api/v3/'.freeze

  def initialize(arguments)
    super(arguments)
    set_connection
  end

  def mobile_build
    super(project_url)
  end

  def user
    response = send_request('user', :get)
    operation_status(response)
  end

  def project_by_name(name)
    response = send_request('projects/' + name.sub('/', '%2F'), :get)
    operation_status(response)
  end

  def check_connection
    response = send_request('user', :get)
    raise StandardError unless operation_status(response)[:complete]
  end

  def create_issue(attributes)
    path = "projects/#{service_project_id}/issues"
    response = send_request(path, :post) do |req|
      req.body = issue_attributes(attributes)
    end
    operation_status(response, parse_issue(response.body))
  end

  def update_issue(attributes, issue_id)
    path = "projects/#{service_project_id}/issues/#{issue_id}"
    response = send_request(path, :put) do |req|
      req.body = issue_attributes(attributes)
    end
    operation_status(response, parse_issue(response.body))
  end

  def destroy_issue(issue_id)
    path = "projects/#{service_project_id}/issues/#{issue_id}"
    response = send_request(path, :delete)
    operation_status(response, parse_issue(response.body))
  end

  def show_issue(issue_id)
    path = "projects/#{service_project_id}/issues/#{issue_id}"
    response = send_request(path, :get)
    operation_status(response, parse_issue(response.body))
  end

  def all_service_issues
    path = "projects/#{service_project_id}/issues?per_page=100"
    response = send_request(path, :get)
    issues = response.body

    page_ranges(response).each do |i|
      issues += send_request("#{path}&page=#{i}", :get).body
    end

    parse_all_issues(issues)
  end

  private

  def set_connection
    @connection = Faraday.new(url: base_url, ssl: { verify: false}) do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
  end

  def send_request(url, html_method, &block)
    @connection.send(html_method) do |req|
      req.url API_PATH + url
      req.headers['Content-Type'] = 'application/json'
      req.headers['PRIVATE-TOKEN'] = access_token
      yield(req) if block.present?
    end
  end

  def issue_attributes(attributes)
    summary = attributes['summary'] || attributes[:summary]
    attributes['title'] = summary if summary
    attributes['state_event'] = state(attributes) if attributes['status_id']
    attributes.slice('title', 'description', 'state_event', :description)
  end

  def state(attributes)
    attributes['status_id'] == Status::DEFAULT_STATUSES[:closed][:id] ? 'close' : 'reopen'
  end

  def page_ranges(response)
    2..response.headers['X-Total-Pages'].to_i
  end

  def parse_all_issues(issues)
    issues.each_with_object({}) do |issue, parsed_issues|
      parsed_issue = parse_issue(issue)
      parsed_issues[parsed_issue[:id]] = parsed_issue
    end
  end

  def parse_issue(issue)
    {
      id: issue['id'].to_s,
      status_id: retrive_state_id(issue),
      description: issue['description'],
      summary: issue['title']
    }
  end

  def retrive_state_id(issue)
    issue['state'] == 'closed' ? Status::DEFAULT_STATUSES[:closed][:id] : Status::DEFAULT_STATUSES[:submitted][:id]
  end
end
