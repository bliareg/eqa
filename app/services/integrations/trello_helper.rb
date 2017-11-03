class TrelloHelper < IntegrationHelper
  attr_accessor :api_key, :member_token, :service_board_id,
                :board_name, :native_statuses
  LIMIT = 1000
  NAME = 'name'.freeze

  def initialize(arguments)
    super(arguments)
    set_connection
  end

  def create_issue(attributes)
    issue_attributes(attributes).merge!(key: api_key, token: member_token)
    @issue_params[:idList] ||= @available_statuses[0].try('[]', 'id')
    response = send_request('cards', :post) do |req|
      req.body = @issue_params
    end
    issue_id = { id: response.body['id'] } if response.body.present?
    operation_status(response, issue_id)
  end

  def show_issue(issue_id)
    response = send_request("cards/#{issue_id}", :get) do |req|
      req.params = { key: api_key, token: member_token }
    end
    @available_statuses = get_available_issue_statuses
    parsed_issue = parse_issue(response.body) if response.body.present?
    operation_status(response, parsed_issue)
  end

  def update_issue(attributes, issue_id)
    path = "cards/#{issue_id}"
    response = send_request(path, :put) do |req|
      req.params = issue_attributes(attributes).merge(key: api_key, token: member_token)
    end
    issue_id = { id: response.body['id'].to_s } if response.body.present?
    operation_status(response, issue_id)
  end

  def destroy_issue(issue_id)
    path = "cards/#{issue_id}"
    response = send_request(path, :delete) do |req|
      req.params = { key: api_key, token: member_token }
    end
    operation_status(response)
  end

  def all_service_issues
    issues = []
    path = "boards/#{service_board_id}/cards"
    response = send_request(path, :get) do |req|
      req.params = { key: api_key, token: member_token, limit: LIMIT }
    end
    issues += response.body
    while response.body.size == LIMIT do
      response = send_request(path, :get) do |req|
        req.params = { key: api_key, token: member_token,
                       limit: LIMIT, before: response.body[0]['id'] }
      end
      issues += response.body
    end
    parse_all_issues(issues)
  end

  def retrieve_board_id
    response = send_request('member/me/boards', :get) do |req|
      req.params = { key: api_key, token: member_token }
    end
    board = response.body.select { |board| board[NAME] == board_name }
    raise StandardError unless board
    board[0]['id']
  end

  private

  def issue_attributes(attributes)
    @issue_params = {}

    summary = attributes['summary'] || attributes[:summary]
    @issue_params[:name] = summary if summary

    description = attributes['description'] || attributes[:description]
    @issue_params[:desc] = description if description
    set_status(attributes)
    @issue_params
  end

  def set_status(attributes)
    @available_statuses = get_available_issue_statuses
    id = check_similar_statuses(attributes)
    @issue_params[:idList] = id if id.present?
  end

  def get_available_issue_statuses
    path = "boards/#{service_board_id}/lists"
    send_request(path, :get) do |req|
      req.params = { key: api_key, token: member_token }
    end.body
  end

  def check_similar_statuses(attributes)
    current_status = Status.find_by(id: attributes['status_id']).name.downcase
    service_list = @available_statuses.find { |s| s[NAME].downcase == current_status }
    service_list['id'] if service_list.present?
  end

  def parse_issue(issue)
    {
      id: issue['id'].to_s,
      summary: issue[NAME],
      description: issue['desc'].to_s
    }.merge!(retrieve_status(issue['idList']))
  end

  def retrieve_status(list_id)
    hash = {}
    current_status = @available_statuses.find { |s| s['id'] == list_id }
    status = native_statuses.find { |st| st.name.downcase == current_status[NAME].downcase }
    hash[:status_id] = status.id if status
    hash
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
      yield(req) if block.present?
    end
  end

  def set_connection
    @connection = Faraday.new(url: 'https://api.trello.com/1') do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
  end
end
