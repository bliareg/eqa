class YouTrackHelper < IntegrationHelper
  attr_accessor :user_cookie,
                :base_url,
                :service_pid,
                :login,
                :password,
                :agile_board_name,
                :sprint_name,
                :priorities,
                :types,
                :statuses,
                :native_statuses

  ENUMERATORS = [:types, :priorities].freeze
  API_PATH = 'rest/'.freeze

  def initialize(arguments)
    super(arguments)
    set_connection
    set_user_cookie
  end

  def check_connection
    raise StandardError if user_cookie.nil?
  end

  def create_issue(attributes)
    response = send_request('issue', :put) do |req|
      req.params = issue_attributes(attributes)
      req.params[:project] = service_pid
    end
    issue_id = response.headers['location'][/(?<=rest\/issue\/).*$/]
    response = update_issue_atributes(attributes.merge(issue_id: issue_id))
    operation_status(response, id: issue_id)
  end

  def update_issue(attributes, issue_id)
    send_request('issue/' + issue_id, :post) do |req|
      req.params = issue_attributes(attributes)
    end
    response = update_issue_atributes(attributes.merge(issue_id: issue_id))
    operation_status(response, id: issue_id)
  end

  def destroy_issue(issue_id)
    response = send_request('issue/' + issue_id, :delete)
    operation_status(response, id: issue_id)
  end

  def show_issue(issue_id)
    response = send_request('issue/' + issue_id, :get)
    operation_status(response, retrive_issue(response.body['issue']))
  end

  def create_attachment(file_path, file_content_type, issue_id)
    path = "issue/#{issue_id}/attachment"
    response = send_request(path, :post) do |req|
      req.body = { files: attachment(file_path, file_content_type) }
      req.headers['Content-Type'] = 'multipart/form-data'
    end
    operation_status(response, parse_attachment(response))
  end

  def destroy_attachment(issue_id, attachment_id)
    path = "issue/#{issue_id}/attachment/#{attachment_id}"
    response = send_request(path, :delete)
    operation_status(response)
  end

  def all_service_issues
    response = get_issues_from_youtrack
    parsed_issues = parse_all_issues(response.body['issues'])
    issues = parsed_issues
    while parsed_issues.size == 500 do
      response = get_issues_from_youtrack(issues.size)
      parsed_issues = parse_all_issues(response.body['issues'])
      issues.merge!(parsed_issues)
    end
    issues
  end

  private

  def get_issues_from_youtrack(after = nil)
    path = "issue/byproject/#{service_pid}"
    send_request(path, :get) do |req|
      req.params[:max] = 500
      req.params[:filter] = board_attributes
      req.params[:after] = after if after
    end
  end

  def set_connection
    @connection = Faraday.new(url: base_url) do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      faraday.response :xml, content_type: /\bxml$/
      faraday.adapter Faraday.default_adapter
    end
  end

  def set_user_cookie
    path = 'user/login'
    response = send_request(path, :post) do |req|
      req.params = {
        login: login,
        password: password
      }
    end
    self.user_cookie = response.headers['set-cookie']
  end

  def send_request(url, html_method, &block)
    @connection.send(html_method) do |req|
      req.url API_PATH + url
      req.headers['Content-Type'] = 'application/xml'
      req.headers['Cookie'] = user_cookie if user_cookie.present?
      yield(req) if block.present?
    end
  end

  def issue_attributes(attributes)
    attributes.slice('summary', :summary,
                     'description', :description)
  end

  def update_issue_atributes(attributes)
    set_enumerators unless types && priorities
    set_statuses unless statuses

    path = "issue/#{attributes[:issue_id]}/execute"
    send_request(path, :post) do |req|
      req.params[:command] = "#{update_board_attributes if agile_board_name.present?} " \
                             "#{issue_update_command(attributes)}"
    end
  end

  def set_enumerators
    path = 'admin/customfield/bundle/'
    ENUMERATORS.each do |enum|
      response = send_request(path + enum.to_s, :get)
      send("#{enum}=", retrive_enum_arrays(response))
    end
  end

  def retrive_enum_arrays(response)
    response.body['enumeration']['value'].map do |field|
      (field['__content__'] || field).downcase
    end
  end

  def set_statuses
    path = 'admin/agile'
    response = send_request(path, :get)
    agile_board = retrive_agile_board(response)
    self.statuses = retrive_statuses(agile_board)
  end

  def retrive_agile_board(response)
    agile_settings = response.body['projectAgileSettingss']['agileSettings']
    if agile_settings.is_a? Array
      agile_settings.find { |board| board['name'] == agile_board_name } || agile_settings[1]
    else
      agile_settings
    end
  end

  def retrive_statuses(agile_board)
    agile_board['columnSettings']['visibleValues']['column'].map do |state|
      state['value'].downcase
    end
  end

  def update_board_attributes
    "add Board #{agile_board_name} #{sprint_name}"
  end

  def issue_update_command(attributes)
    type_command(attributes['issue_type']) +
      priority_command(attributes['priority']) +
      status_command(attributes['status_id'])
  end

  def type_command(issue_type)
    type_name = Issue.issue_type.find_value(issue_type).tr('_', ' ')
    type_name.in?(types) ? "Type #{type_name} " : ''
  end

  def priority_command(priority)
    priority_name = Issue.priority.find_value(priority).tr('_', ' ')
    priority_name.in?(priorities) ? "Priority #{priority_name} " : ''
  end

  def status_command(status_id)
    status_name = Status.find(status_id).name.downcase
    status_name.in?(statuses) ? "State #{status_name} " : ''
  end

  def retrive_issue(response_issue)
    return false unless response_issue

    issue = response_issue['field'].each_with_object({}) do |field, object|
      object[field['name']] = field['value'] if field['value'].present?
    end
    issue[:id] = response_issue['id']
    parse_issue(issue)
  end

  def parse_issue(issue)
    parsed_issue = {
      summary: issue['summary'],
      description: issue['description'],
      id: issue[:id]
    }
    parsed_issue.merge(retrive_attributes(issue))
  end

  def retrive_attributes(issue)
    attributes = {}

    attributes[:issue_type] = issue['Type'].downcase \
      if issue['Type'].downcase.in?(Issue.issue_type.values)

    attributes[:priority] = issue['Priority'].downcase \
      if issue['Priority'].downcase.in?(Issue.priority.values)

    status = native_statuses.find { |st| st.name == issue['State'] }
    attributes[:status_id] = status.id if status.present?

    attributes
  end

  def attachment(file_path, file_content_type)
    Faraday::UploadIO.new(file_path, file_content_type)
  end

  def board_attributes
    "Board #{agile_board_name}: {#{sprint_name}}"
  end

  def parse_all_issues(response_issues)
    return {} unless response_issues
    return {
      response_issues['issue']['id'] => retrive_issue(response_issues['issue'])
    } if response_issues['issue'].instance_of? Hash

    response_issues['issue'].each_with_object({}) do |response_issue, parsed_issues|
      issue = retrive_issue(response_issue)
      parsed_issues[issue[:id]] = issue
    end
  end

  def parse_attachment(response)
    { id: response.body['fileUrl']['id'] }
  end
end
