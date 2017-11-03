class RedmineHelper < IntegrationHelper
  attr_accessor :base_url, :api_key, :project_name, :service_project_id,
                :tracker_name, :tracker_id, :native_statuses

  LIMIT = 100.freeze
  NAME = 'name'.freeze
  ISSUE = 'issue'.freeze

  def initialize(arguments)
    super(arguments)
    set_connection
  end

  def create_issue(attributes)
    response = send_request('issues.json', :post) do |req|
      req.body = issue_attributes(attributes)
    end
    issue_id = { id: response.body[ISSUE]['id'].to_s } if response.body.present?
    operation_status(response, issue_id)
  end

  def show_issue(issue_id)
    response = send_request("issues/#{issue_id}.json", :get)
    @available_statuses = get_available_issue_statuses
    parsed_issue = parse_issue(response.body[ISSUE]) if response.body.present?
    operation_status(response, parsed_issue)
  end

  def update_issue(attributes, issue_id)
    path = "issues/#{issue_id}.json"
    response = send_request(path, :put) do |req|
      req.body = issue_attributes(attributes)
    end
    issue_id = { id: response.body[ISSUE]['id'].to_s } if response.body.present?
    operation_status(response, issue_id)
  end

  def destroy_issue(issue_id)
    path = "issues/#{issue_id}.json"
    response = send_request(path, :delete)
    operation_status(response)
  end

  def all_service_issues
    issues = []
    response = send_request(new_path(issues.size), :get)
    issues += response.body['issues']
    repeat_several(response.body).times do
      response = send_request(new_path(issues.size), :get)
      issues += response.body['issues']
    end
    parse_all_issues(issues)
  end

  def check_connection
    response = send_request('users/current.json', :get)
    raise StandardError unless response.body
  end

  def retrieve_object_id(key, begin_from = 0)
    path = "#{key.pluralize}.json?limit=#{LIMIT}&offset=#{begin_from}"
    response = send_request(path, :get)
    object = response.body[key.pluralize].find { |o| o[NAME] == send("#{key}_name") }
    if object
      object['id']
    elsif object.nil? && has_next_page?(response)
      retrieve_object_id(key, (response.body['offset'] + LIMIT))
    else
      raise t("#{key}_not_found")
    end
  end

  private

  def issue_attributes(attributes)
    @issue_params = { issue: { project_id: service_project_id,
                              tracker_id: tracker_id } }

    subject = attributes['summary'] || attributes[:summary]
    @issue_params[:issue][:subject] = subject if subject

    description = attributes['description'] || attributes[:description]
    @issue_params[:issue][:description] = description if description

    set_priority(attributes)
    set_status(attributes)
    @issue_params
  end

  def set_priority(attributes)
    @available_priorities = get_available_issue_priorities
    current_priority = Issue.priority.values[attributes['priority']]
    @issue_params[:issue][:priority_id] = @available_priorities.find { |p| p[NAME].downcase == current_priority }.try('[]', 'id')
    @issue_params[:issue][:priority_id] ||= @available_priorities.find { |p| p['is_default'] == true }['id']
  end

  def get_available_issue_priorities
    path = 'enumerations/issue_priorities.json'
    send_request(path, :get).body['issue_priorities']
  end

  def set_status(attributes)
    @available_statuses = get_available_issue_statuses
    case attributes['status_id']
    when Status::DEFAULT_STATUSES[:closed][:id]
      id = @available_statuses.find { |s| s['is_closed'] == true }.try('[]', 'id')
    when Status::DEFAULT_STATUSES[:submitted][:id]
      id = @available_statuses.find { |s| s['is_default'] == true }.try('[]', 'id')
    end
    id ||= check_similar_statuses(attributes)
    @issue_params[:issue][:status_id] = id if id.present?
  end

  def get_available_issue_statuses
    path = 'issue_statuses.json'
    send_request(path, :get).body['issue_statuses']
  end

  def check_similar_statuses(attributes)
    current_status = Status.find_by(id: attributes['status_id']).name.downcase
    @available_statuses.find { |s| s[NAME].downcase == current_status }.try('[]', 'id')
  end

  def parse_issue(issue)
    {
      id: issue['id'].to_s,
      summary: issue['subject'],
      description: issue['description'].to_s
    }.merge!(retrieve_attributes(issue))
  end

  def retrieve_attributes(issue)
    attributes = {}
    attributes[:priority] = issue['priority'][NAME].downcase \
      if issue['priority'][NAME].downcase.in?(Issue.priority.values)
    status_id = retrieve_status_id(issue['status'])
    attributes[:status_id] = status_id if status_id.present?
    attributes
  end

  def retrieve_status_id(status)
    current_status = @available_statuses.find { |s| s[NAME] == status[NAME] }

    return Status::DEFAULT_STATUSES[:submitted][:id] if current_status['is_default']
    return Status::DEFAULT_STATUSES[:closed][:id] if current_status['is_closed']

    native_statuses.find { |st| st.name.downcase == current_status[NAME].downcase }.try('id')
  end

  def repeat_several(body)
    total = body['total_count']
    count = total / LIMIT
    (total % LIMIT).zero? ? count - 1 : count
  end

  def parse_all_issues(issues)
    return {} unless issues
    @available_statuses = get_available_issue_statuses
    issues.each_with_object({}) do |issue, parsed_issues|
      parsed_issue = parse_issue(issue)
      parsed_issues[parsed_issue[:id]] = parsed_issue
    end
  end

  def send_request(url, html_method, &block)
    @connection.send(html_method) do |req|
      req.url url
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-Redmine-API-Key'] = api_key
      yield(req) if block.present?
    end
  end

  def set_connection
    @connection = Faraday.new(url: base_url) do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
  end

  def has_next_page?(response)
    response.body['total'] < (response.body['offset'] + LIMIT)
  end

  def new_path(begin_from)
    "issues.json?project_id=#{service_project_id}&tracker_id=#{tracker_id}&offset=#{begin_from}&status_id=*&limit=#{LIMIT}"
  end
end
