require 'rails_helper'
require 'spec_helper'
require 'rspec_api_documentation'
require 'rspec_api_documentation/dsl'
include Rails.application.routes.url_helpers

RspecApiDocumentation.configure do |config|
  config.format = [:json]
  config.curl_host = 'http://localhost:3000'
  config.api_name = 'EasyQA API'
end

def set_variables_for_api
  Status::DEFAULT_STATUSES.each_value do |params_status|
    Status.create(name: params_status[:name])
  end
  Status.first.update_attribute(:id, 1)

  @owner = create(:user, with_token: true)
  @organization = create(:organization, owner_id: @owner.id)
  @project = create(:project, user_id: @owner.id, organization_id: @organization.id)

  @developer = create(:user, with_token: true, project: @project, role: :developer)
  @not_project_member = create(:user, with_token: true, organization: @organization, role: :user)
  @organization_user = create(:user, with_token: true, organization: @organization, role: :user)
  @not_organization_member = create(:user, with_token: true)
  @viewer = create(:user, with_token: true, project: @project, role: :viewer)
end
