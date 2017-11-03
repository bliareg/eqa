class GitHubHelper < IntegrationHelper
  include MobileBuilder

  attr_accessor :base_url, :access_token, :repository_name,
                :project_id, :username, :repository_url, :branch

  BODY = 'body'.freeze
  TITLE = 'title'.freeze
  STATE = 'state'.freeze
  CLOSED_STATUS = 'closed'.freeze
  NUMBER = 'number'.freeze

  def initialize(arguments)
    super(arguments)
    set_connection
  end

  def mobile_build
    super(repository_url)
  end

  def user
    response = send_request('user', :get)
    operation_status(response)
  end

  def all_service_issues
    path = "repos/#{repository_name}/issues?state=all&per_page=100"
    response = send_request(path, :get)
    issues = response.body
    if response.headers['link']
      pages_count = get_pages_count(response.headers)
      (2..pages_count).each do |i|
        issues += send_request("#{path}&page=#{i}", :get).body
      end
    end
    parse_all_issues(issues)
  end

  def create_issue(attributes)
    response = send_request("repos/#{repository_name}/issues", :post) do |req|
      req.body = issue_attributes(attributes)
    end
    operation_status(response, parse_issue(response.body))
  end

  def update_issue(attributes, issue_id)
    path = "repos/#{repository_name}/issues/#{issue_id}"
    response = send_request(path, :patch) do |req|
      req.body = issue_attributes(attributes)
    end
    operation_status(response, parse_issue(response.body))
  end

  def destroy_issue(issue_id)
    path = "repos/#{repository_name}/issues/#{issue_id}"
    response = send_request(path, :patch) do |req|
      req.body = { STATE => CLOSED_STATUS }
    end
    operation_status(response)
  end

  def show_issue(issue_id)
    response = send_request("repos/#{repository_name}/issues/#{issue_id}", :get)
    operation_status(response, parse_issue(response.body))
  end

  def check_connection
    response = send_request('user', :get)
    raise StandardError unless operation_status(response)[:complete]
    response = send_request("repos/#{repository_name}", :get)
    raise StandardError unless operation_status(response)[:complete]
  end

  def destroy_repository
    path = "repos/#{repository_name}"
    response = send_request(path, :delete)
    operation_status(response)
  end

  def create_repository(name)
    response = send_request('user/repos', :post) do |req|
      req.body = { 'name' => name }
    end
    operation_status(response)
  end

  private

  def get_pages_count(headers)
    # 'link' => "<https://api.github.com/repositories/63955202/issues?per_page=2&state=all&page=4>; rel=\"last\",
    #            <https://api.github.com/repositories/63955202/issues?per_page=2&state=all&page=2>; rel=\"next\""
    links = {}
    parts = headers['link'].split(',')
    parts.each do |part|
      section = part.split(';')
      url = section[0][/<(.*)>/, 1]
      name = section[1][/rel="(.*)"/, 1].to_sym
      links[name] = url
    end
    # links = {last: "https://api.github.com/repositories/63955202/issues?per_page=2&state=all&page=4",
    #          next: "https://api.github.com/repositories/63955202/issues?per_page=2&state=all&page=2"}
    links[:last][links[:last].rindex('=') + 1, links[:last].size].to_i
  end

  def issue_attributes(attributes)
    summary = attributes['summary'] || attributes[:summary]
    attributes[TITLE] = summary if summary
    attributes[STATE] = state(attributes) if attributes['status_id']
    attributes[BODY] = attributes['description'] || attributes[:description]
    attributes.slice(TITLE, BODY, STATE)
  end

  def state(attributes)
    attributes['status_id'] == Status::DEFAULT_STATUSES[:closed][:id] ? CLOSED_STATUS : 'open'
  end

  def parse_issue(issue)
    {
      id: issue[NUMBER].to_s,
      status_id: retrieve_status(issue[STATE]),
      description: issue[BODY],
      summary: issue[TITLE]
    }
  end

  def retrieve_status(state)
    state == CLOSED_STATUS ? Status::DEFAULT_STATUSES[:closed][:id] : Status::DEFAULT_STATUSES[:submitted][:id]
  end

  def send_request(url, html_method, &block)
    @connection.send(html_method) do |req|
      req.url url
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = 'token ' + access_token
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

  def parse_all_issues(issues)
    issue_ids = ids_for_synchronize
    issues.each_with_object({}) do |issue, parsed_issues|
      next if issue[STATE] == CLOSED_STATUS && !issue[NUMBER].to_s.in?(issue_ids)
      parsed_issue = parse_issue(issue)
      parsed_issues[parsed_issue[:id]] = parsed_issue
    end
  end

  def ids_for_synchronize
    project = Project.find(project_id)
    project.plugins.where(name: 'git_hub_setting').pluck(:service_id)
  end
end
