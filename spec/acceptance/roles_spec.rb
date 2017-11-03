require 'acceptance_helper'

resource 'Roles' do
  before :all do
    set_variables_for_api
    5.times { create(:organization, owner_id: @owner.id) }
  end

  parameter :auth_token, 'User authenticity token', required: true

  get api_v1_organization_roles_path(':organization_id') do
    header 'Content-Type', 'application/json'

    parameter :organization_id, 'Organization id', required: true
    let(:organization_id) { @organization.id }

    example 'Organization Index' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      status.should == 200
    end
  end

  get api_v1_organization_roles_path(':organization_id') do
    header 'Content-Type', 'application/json'

    parameter :organization_id, 'Organization id', required: true
    parameter :token, 'Project token', required: true

    let(:organization_id) { @organization.id }
    let(:token) { @project.token }

    example 'Project Index' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      status.should == 200
    end
  end

  get api_v1_role_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :id, 'Role id', required: true
    let(:id) { @organization.owner_role.id }

    example 'Show' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      status.should == 200
    end
  end

  post api_v1_organization_roles_path(':organization_id') do
    header 'Content-Type', 'application/json'

    parameter :organization_id, 'Organization id', required: true
    parameter :role, 'Role in organization. Must be "user" or "admin"', required: true
    parameter :user_id, 'User id', required: true

    let(:organization_id) { @organization.id }
    let(:role) { 'user' }
    let(:user_id) { @not_organization_member.id }
    let(:raw_post) { params.to_json }

    example 'Create organization role by user id' do
      do_request(
        auth_token: @owner.authenticity_tokens.last.token,
      )

      expect(status).to be 200
    end
  end

  post api_v1_organization_roles_path(':organization_id') do
    header 'Content-Type', 'application/json'

    parameter :organization_id, 'Organization id', required: true
    parameter :role, 'Role in organization. Must be "user" or "admin"', required: true
    parameter :email, 'User email', required: true

    let(:organization_id) { @organization.id }
    let(:role) { 'user' }
    let(:email) { @not_organization_member.email }
    let(:raw_post) { params.to_json }

    example 'Create organization role by user email' do
      do_request(
        auth_token: @owner.authenticity_tokens.last.token,
      )

      expect(status).to be 200
    end
  end

  post api_v1_organization_roles_path(':organization_id') do
    header 'Content-Type', 'application/json'

    parameter :organization_id, 'Organization id', required: true
    parameter :token, 'Project token', required: true
    parameter :role, 'Role in project. Must be "developer", "tester", "viewer" or "project_manager"', required: true
    parameter :user_id, 'User id', required: true

    let(:organization_id) { @organization.id }
    let(:role) { 'developer' }
    let(:user_id) { @organization_user.id }
    let(:token) { @project.token }
    let(:raw_post) { params.to_json }

    example 'Create project role by user id' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end
  end

  post api_v1_organization_roles_path(':organization_id') do
    header 'Content-Type', 'application/json'

    parameter :organization_id, 'Organization id', required: true
    parameter :token, 'Project token', required: true
    parameter :role, 'Role in project. Must be "developer", "tester", "viewer" or "project_manager"', required: true
    parameter :user_id, 'User id', required: true
    parameter :email, 'User email', required: true

    let(:organization_id) { @organization.id }
    let(:role) { 'developer' }
    let(:email) { @organization_user.email }
    let(:token) { @project.token }
    let(:raw_post) { params.to_json }

    example 'Create project role by user email' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end
  end

  put api_v1_role_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :id, 'Role id', required: true
    parameter :role, 'Role in organization. Must be "user" or "admin"'

    let(:id) { @organization.roles.find_by(project_id: nil, user_id: @organization_user.id).id }
    let(:role) { 'admin' }
    let(:user_id) { @organization_user.id }
    let(:raw_post) { params.to_json }

    example 'Update organization role' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end
  end

  put api_v1_role_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :id, 'Role id', required: true
    parameter :role, 'Role in project. Must be "developer", "tester", "viewer" or "project_manager"'

    let(:id) { @organization.roles.find_by(project_id: @project.id, user_id: @developer.id).id }
    let(:role) { 'tester' }
    let(:raw_post) { params.to_json }

    example 'Update project role' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end
  end

  delete api_v1_role_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :id, 'Role id', required: true

    let(:id) { @organization.roles.find_by(project_id: @project.id, role: Role.developer_value).id }
    let(:raw_post) { params.to_json }

    example 'Delete' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end

    example 'Delete. Not owner' do
      do_request(auth_token: @developer.authenticity_tokens.last.token)

      expect(status).to be 403
    end
  end
end
