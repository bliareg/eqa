class JiraHelper < IntegrationHelper
  attr_accessor :username, :password, :site, :board_name, :board_id,
                :context_path, :project_key, :sprint_support, :native_statuses

  TYPE_TASK = 'Task'.freeze
  TYPE_EPIC = 'epic'.freeze
  DEFAULT_STATUS_ID = '11'.freeze
  EPIC_NAME_COLUMN = 'customfield_10005'.freeze
  CLOSED_STATUS = 'done'.freeze
  PRIORITY_HASH = { 'lowest' => '5',
                    'low' => '4',
                    'medium' => '3',
                    'high' => '2',
                    'highest' => '1' }.freeze

  def initialize(arguments)
    super(arguments)
    @client = set_client
  end

  def create_issue(attributes)
    issue = @client.Issue.build
    issue.save(issue_attributes(attributes))
    work_with_sprint(issue.attrs['id']) if issue.attrs['errors'].nil? && sprint_support
    operation_status(issue.attrs)
  end

  def show_issue(issue_id)
    issue = @client.Issue.find(issue_id)
    get_default_status_name(issue.attrs)
    operation_status(issue.attrs, parse_issue(issue.attrs))
  rescue JIRA::HTTPError
    operation_status('errors' => { 'show' => 'Issue does not exist.' })
  end

  def update_issue(attributes, issue_id)
    issue = @client.Issue.find(issue_id)
    response = issue.attrs
    if issue.save(issue_attributes(attributes, !response['fields']['issuetype']['subtask']))
      work_with_sprint(issue_id) if sprint_support
      change_status(issue, attributes)
    else
      response = { 'errors' => { 'update' => 'Could not update issue.' } }
    end
    operation_status(response)
  end

  def destroy_issue(issue_id)
    issue = @client.Issue.find(issue_id)
    response = issue.attrs
    response = { 'errors' => { 'delete' => 'Could not delete issue.' } } unless issue.delete
    operation_status(response)
  end

  def check_connection
    @client.Project.find(project_key)
  end

  def retrieve_board_id
    path = "/rest/agile/1.0/board?projectKeyOrId=#{project_key}"
    response = JSON.parse(@client.get(path).read_body)
    boards_hash = response['values'].each_with_object({}) do |board, boards|
      boards[board['name']] = board['id']
    end
    board_id = boards_hash[board_name]
    raise StandardError if board_id.nil?
    board_id
  end

  def retrieve_sprint_support
    path = "/rest/agile/1.0/board/#{board_id}/sprint?state=active"
    @client.get(path).read_body
    true
  rescue JIRA::HTTPError
    false
  end

  def all_service_issues
    path = @client.options[:rest_base_path] + '/search'
    start_at = 0
    issues = []
    response = JSON.parse(@client.post(path, request_body(start_at).to_json)
                                 .read_body)
    issues += response['issues']
    repeat_several(response).times do
      issues += JSON.parse(@client.post(path, request_body(issues.size).to_json)
                                  .read_body)['issues']
    end
    parse_all_issues(issues)
  end

  private

  def set_client
    options = {
      username: username,
      password: password,
      site: site,
      context_path: context_path,
      auth_type: :basic,
      read_timeout: 120
    }
    JIRA::Client.new(options)
  end

  def issue_attributes(attributes, send_issue_type = true)
    issue_params = { fields: { project: { key: project_key } } }

    summary = attributes['summary'] || attributes[:summary]
    issue_params[:fields][:summary] = summary if summary

    description = attributes['description'] || attributes[:description]
    issue_params[:fields][:description] = description if description

    set_enumerators(issue_params, attributes, send_issue_type)
    issue_params[:fields][EPIC_NAME_COLUMN] = issue_params[:fields][:summary] if issue_params[:fields][:issuetype] && issue_params[:fields][:issuetype][:id] == @available_issue_types[TYPE_EPIC]
    issue_params
  end

  def set_enumerators(issue_params, attributes, send_issue_type)
    get_available_issue_types
    if send_issue_type
      issue_params[:fields][:issuetype] = {}
      issue_params[:fields][:issuetype][:id] = issue_type(attributes)
    end
    issue_params[:fields][:priority] = {}
    issue_params[:fields][:priority][:id] = priority(attributes)
    issue_params
  end

  def get_available_issue_types
    path = @client.options[:rest_base_path] + "/project/#{project_key}?expand=issueTypes"

    types = JSON.parse(@client.get(path).read_body)['issueTypes']
    @available_issue_types = types.each_with_object({}) do |type, result|
      result[type['name'].downcase] = type['id'] unless type['subtask']
    end
  end

  def issue_type(attributes)
    current_issue_type = Issue.issue_type
                              .values[attributes['issue_type']]
                              .tr('_', ' ')
    @available_issue_types.delete(TYPE_EPIC) if @available_issue_types.count > 1
    @available_issue_types[current_issue_type] || @available_issue_types[TYPE_TASK] || @available_issue_types.values.first
  end

  def priority(attributes)
    current_priority = Issue.priority.values[attributes['priority']]
    PRIORITY_HASH[current_priority]
  end

  def work_with_sprint(issue_id)
    sprint_id = find_active_sprint
    add_to_sprint(sprint_id, issue_id) if sprint_id.present?
  end

  def find_active_sprint
    path = "/rest/agile/1.0/board/#{board_id}/sprint?state=active"
    response = JSON.parse(@client.get(path).read_body)
    response['values'].first.try('[]', 'id')
  end

  def add_to_sprint(sprint_id, issue_id)
    path = "/rest/agile/1.0/sprint/#{sprint_id}/issue"
    id = { 'issues' => [issue_id] }
    @client.post(path, id.to_json)
  end

  def operation_status(response, parsed_issue = nil)
    message = response['errors'].values.first if response['errors']
    complete = message.nil?
    message = 'Success' if complete
    {
      complete: complete,
      message:   message,
      body:      parsed_issue || { id: response['id'] }
    }
  end

  def get_default_status_name(issue)
    available_statuses = get_available_statuses(issue)
    @default_status = available_statuses.select{ |key, value| value == DEFAULT_STATUS_ID }
                                        .keys.first
  end

  def change_status(issue, attributes)
    id = set_status_id(issue, attributes)
    if id.present?
      transation = issue.transitions.build
      transation.save!('transition' => { 'id' => id })
    end
  end

  def set_status_id(issue, attributes)
    id = DEFAULT_STATUS_ID if attributes['status_id'] == Status::DEFAULT_STATUSES[:submitted][:id]
    id ||= check_closed_status(issue, attributes)
    id ||= check_other_statuses(attributes)
  end

  def check_closed_status(issue, attributes)
    @available_statuses = get_available_statuses(issue.attrs)
    @available_statuses[CLOSED_STATUS] if attributes['status_id'] == Status::DEFAULT_STATUSES[:closed][:id]
  end

  def get_available_statuses(issue)
    path = @client.options[:rest_base_path] + "/issue/#{issue['id']}/transitions"
    transitions = JSON.parse(@client.get(path).read_body)['transitions']
    transitions.each_with_object({}) do |status, result|
      result[status['name'].downcase] = status['id']
    end
  end

  def check_other_statuses(attributes)
    status_name = Status.find_by(id: attributes['status_id']).name.downcase
    @available_statuses[status_name]
  end

  def request_body(start_at)
    { 'jql' => "project = #{project_key}",
      'fields' => %w(summary description status priority issuetype),
      'fieldsByKeys' => false,
      'maxResults' => 1000,
      'startAt' => start_at }
  end

  def repeat_several(response)
    total = response['total']
    max_results = response['maxResults']
    count = total / max_results
    (total % max_results).zero? ? count - 1 : count
  end

  def parse_all_issues(issues)
    return {} unless issues.present?
    get_default_status_name(issues.first)
    issues.each_with_object({}) do |issue, parsed_issues|
      parsed_issue = parse_issue(issue)
      parsed_issues[parsed_issue[:id]] = parsed_issue
    end
  end

  def parse_issue(issue)
    parsed_issue = { id: issue['id'].to_s,
                     description: issue['fields']['description'],
                     summary: issue['fields']['summary'] }
    parsed_issue.merge(retrieve_attributes(issue['fields']))
  end

  def retrieve_attributes(issue)
    attributes = {}

    status_id = retrieve_status_id(issue['status'])
    attributes[:status_id] = status_id if status_id.present?

    attributes[:priority] = issue['priority']['name'].downcase

    attributes[:issue_type] = issue['issuetype']['name'].downcase \
      if issue['issuetype']['name'].downcase.in?(Issue.issue_type.values)

    attributes
  end

  def retrieve_status_id(status)
    return Status::DEFAULT_STATUSES[:closed][:id] if status['name'].downcase == CLOSED_STATUS
    return Status::DEFAULT_STATUSES[:submitted][:id] if status['name'].downcase == @default_status
    status = native_statuses.find { |st| st.name == status['name'] }
    status.id if status.present?
  end
end
