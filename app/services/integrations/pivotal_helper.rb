class PivotalHelper < IntegrationHelper
  attr_accessor :project_name, :service_project_id, :api_token, :native_statuses

  BASE_URL = 'https://www.pivotaltracker.com/services/v5/'.freeze
  NAME = 'name'.freeze
  ESTIMATE = 'estimate'.freeze
  LIMIT = 500.freeze

  STORY_TYPE = 'story_type'.freeze
  UNSUPPORTED_TYPES = %w(no_type documentation task usability_problem crash).freeze
  SUPPORTED_TYPES = %w(feature bug).freeze
  FEATURE_TYPE = 'feature'.freeze

  STATE = 'current_state'.freeze
  AVAILABLE_STATUSES = %w(accepted delivered finished started
                          rejected planned unstarted unscheduled).freeze
  UNSCHEDULED_STATUS = 'unscheduled'.freeze
  ACCEPTED_STATUS = 'accepted'.freeze

  def initialize(arguments)
    super(arguments)
    set_connection
  end

  def all_service_issues
    path = "projects/#{service_project_id}/stories?limit=#{LIMIT}"
    response = send_request(path, :get)
    issues = response.body
    repeat_several(response.headers).times do
      issues += send_request("#{path}&offset=#{issues.size}", :get).body
    end
    parse_all_issues(issues)
  end

  def create_issue(attributes)
    path = "projects/#{service_project_id}/stories"
    response = send_request(path, :post) do |req|
      req.body = issue_attributes(attributes)
    end
    issue_id = { id: response.body['id'].to_s } if response.body.present?
    operation_status(response, issue_id)
  end

  def update_issue(attributes, issue_id)
    path = "projects/#{service_project_id}/stories/#{issue_id}"
    response = send_request(path, :put) do |req|
      req.body = issue_attributes(attributes)
    end
    issue_id = { id: response.body['id'].to_s } if response.body.present?
    operation_status(response, issue_id)
  end

  def destroy_issue(issue_id)
    path = "projects/#{service_project_id}/stories/#{issue_id}"
    response = send_request(path, :delete)
    operation_status(response)
  end

  def show_issue(issue_id)
    response = send_request("projects/#{service_project_id}/stories/#{issue_id}", :get)
    operation_status(response, parse_issue(response.body))
  end

  def check_connection
    response = send_request('me', :get)
    raise StandardError unless operation_status(response)[:complete]
  end

  def retrieve_project_id
    response = send_request('projects', :get)
    project = response.body.find { |p| p[NAME] == project_name }
    raise t('project_not_found') unless project
    project['id']
  end

  private

  def repeat_several(headers)
    total = headers['X-Tracker-Pagination-Total'].to_i
    count = total / LIMIT
    (total % LIMIT).zero? ? count - 1 : count
  end

  def issue_attributes(attributes)
    @issue_params = {}
    @issue_params[NAME] = attributes['summary'] || attributes[:summary]
    @issue_params['description'] = attributes['description'] || attributes[:description]
    set_state(attributes['status_id'])
    set_issue_type(attributes['issue_type']) if attributes['issue_type']
    set_priority(attributes['priority']) if @issue_params[STORY_TYPE] == FEATURE_TYPE

    @issue_params
  end

  def set_state(status_id)
    status_name = UNSCHEDULED_STATUS if status_id == Status::DEFAULT_STATUSES[:submitted][:id]
    status_name = ACCEPTED_STATUS if status_id == Status::DEFAULT_STATUSES[:closed][:id]
    status_name ||= Status.find_by_id(status_id).name.downcase
    @issue_params[STATE] = status_name if status_name.in?(AVAILABLE_STATUSES)
  end

  def set_issue_type(type)
    current_issue_type = Issue.issue_type.values[type]
    @issue_params[STORY_TYPE] = current_issue_type.in?(UNSUPPORTED_TYPES) ? 'chore' : current_issue_type
  end

  def set_priority(priority)
    @issue_params[ESTIMATE] = (priority == 4 ? 3 : priority)
  end

  def parse_issue(issue)
    return {} unless issue
    {
      id: issue['id'].to_s,
      summary: issue[NAME],
      description: issue['description']
    }.merge!(retrieve_attributes(issue))
  end

  def retrieve_attributes(issue)
    attributes = {}
    status_id = retrieve_status_id(issue[STATE])
    attributes[:status_id] = status_id if status_id.present?
    attributes[:issue_type] = retrieve_issue_type(issue[STORY_TYPE])
    attributes[:priority] = Issue.priority.values[issue[ESTIMATE]] if \
      attributes[:issue_type] == FEATURE_TYPE && issue[ESTIMATE]
    attributes
  end

  def retrieve_status_id(status)
    return Status::DEFAULT_STATUSES[:submitted][:id] if status == UNSCHEDULED_STATUS
    return Status::DEFAULT_STATUSES[:closed][:id] if status == ACCEPTED_STATUS
    native_statuses.find { |st| st.name.downcase == status.downcase }.try('id')
  end

  def retrieve_issue_type(story_type)
    return story_type if story_type.in?(SUPPORTED_TYPES)
    'task'
  end

  def send_request(url, html_method, &block)
    @connection.send(html_method) do |req|
      req.url url
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-TrackerToken'] = api_token
      yield(req) if block.present?
    end
  end

  def set_connection
    @connection = Faraday.new(url: BASE_URL) do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
  end

  def parse_all_issues(issues)
    return {} unless issues
    issues.each_with_object({}) do |issue, parsed_issues|
      parsed_issue = parse_issue(issue)
      parsed_issues[parsed_issue[:id]] = parsed_issue
    end
  end
end
