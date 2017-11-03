require 'acceptance_helper'

resource 'Users' do
  header 'Content-Type', 'application/json'

  before :all do
    set_variables_for_api
  end

  get '/api/v1/projects/members_list' do
    parameter :token, 'Uniq project token', required: true
    let(:token) { @project.token }

    example 'Project members list' do
      do_request

      status.should == 200
    end
  end

  get organization_members_path do
    parameter :organization_id, 'Organization id', required: true
    parameter :auth_token, 'User auth token', required: true
    let(:organization_id) { @organization.id }
    let(:auth_token) { @owner.authenticity_tokens.last.token }

    example 'Organization members list by id' do
      do_request

      status.should == 200
    end
  end

  get organization_members_path do
    parameter :organization_title, 'Organization title', required: true
    parameter :auth_token, 'User auth token', required: true
    let(:auth_token) { @owner.authenticity_tokens.last.token }
    let(:organization_title) { @organization.title }

    example 'Organization members list by title' do
      do_request

      status.should == 200
    end
  end

  get users_show_path do
    parameter :id, 'User id', required: true
    let(:id) { @owner.id }

    example 'User show by id' do
      do_request

      status.should == 200
    end
  end

  get users_show_path do
    parameter :email, 'User email', required: true
    let(:email) { @owner.email }

    example 'User show by email' do
      do_request

      status.should == 200
    end
  end

  post '/api/v1/sign_in' do
    with_options scope: :user, required: true do
      parameter :email, 'User email'
      parameter :password, 'User password'
    end

    let(:email) { @owner.email }
    let(:password) { 'foobarrr' }

    let(:raw_post) { params.to_json }
    example 'Sign in' do
      do_request

      status.should == 200
    end
  end

  delete '/api/v1/sign_out' do
    before do
      @owner.authenticity_tokens << build(:authenticity_token)
    end

    parameter :auth_token, 'User authenticity token', required: true

    let(:auth_token) { @owner.authenticity_tokens.last.token }
    let(:raw_post) { params.to_json }

    example 'Sign out' do
      do_request

      status.should == 200
    end
  end
end
