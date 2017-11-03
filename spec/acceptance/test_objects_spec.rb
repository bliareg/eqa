require 'acceptance_helper'

resource 'Test Objects' do
  before :all do
    set_variables_for_api
    3.times do
      create(:web, user_id: @owner.id, project_id: @project.id)
    end
    @test_object = create(:ipa_build, user_id: @owner.id, project_id: @project.id)
  end
  parameter :token, 'Uniq project token', required: true
  let(:token) { @project.token }

  get api_v1_test_objects_path do
    header 'Content-Type', 'application/json'

    example 'Get all test object links' do
      do_request

      expect(status).to be 200
    end
  end

  get api_v1_test_objects_path do
    header 'Content-Type', 'application/json'

    parameter :auth_token, 'User authenticity token', required: true

    let(:auth_token) { @owner.authenticity_tokens.last.token }

    example 'Index' do
      do_request

      status.should == 200
    end
  end

  get api_v1_test_object_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :auth_token, 'User authenticity token', required: true
    parameter :id, 'Test object ID', required: true
    let(:id)         { @test_object.id }
    let(:raw_post)   { params.to_json }

    example 'Show' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end
  end

  post api_v1_test_objects_path do
    header 'Content-Type', 'multipart/form-data'

    parameter :auth_token, 'User authenticity token', required: true
    parameter :file, 'Your ipa or apk file', 'Type' => 'Multipart/Form-data', required: true

    let(:file) { Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/mobile_builds/app-debug.apk", 'application/apk') }
    let(:auth_token) { @owner.authenticity_tokens.last.token }

    example 'Create. Mobile Build' do
      do_request

      status.should == 200
    end
  end

  post api_v1_test_objects_path do
    header 'Content-Type', 'application/json'

    parameter :auth_token, 'User authenticity token', required: true
    parameter :link, 'Your link to site', required: true

    let(:link) { attributes_for(:web)[:link] }
    let(:auth_token) { @owner.authenticity_tokens.last.token }
    let(:raw_post) { params.to_json }

    example 'Create. Link' do
      do_request

      status.should == 200
    end
  end

  delete api_v1_test_object_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :id, 'Test object ID', required: true
    parameter :auth_token, 'User authenticity token', required: true

    let(:id)         { @test_object.id }
    let(:auth_token) { @owner.authenticity_tokens.last.token }
    let(:raw_post) { params.to_json }

    example 'Delete' do
      do_request

      expect(status).to be 200
    end
  end
end
