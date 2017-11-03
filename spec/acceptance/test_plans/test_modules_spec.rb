require 'acceptance_helper'

resource 'Test Modules' do
  before :all do
    set_variables_for_api
    @test_plan = create(:test_plan, project_id: @project.id, created_by: @owner.id)
    5.times { create(:test_module, test_plan_id: @test_plan.id, created_by: @owner.id) }
    @test_module = create(:test_module, test_plan_id: @test_plan.id, created_by: @owner.id)
  end

  parameter :auth_token, 'User authenticity token', required: true
  parameter :token, 'Uniq project token', required: true

  let(:token) { @project.token }

  get api_v1_test_plan_test_modules_path(':test_plan_id') do
    header 'Content-Type', 'application/json'

    parameter :test_plan_id, 'ID of test plan', required: true
    let(:test_plan_id) { @test_plan.id }

    example 'Index' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      status.should == 200 && response_body.should == @test_plan.test_modules.to_json
    end

    example 'Index. User not project member' do
      do_request(auth_token: @not_project_member.authenticity_tokens.last.token)
      status.should == 403
    end
  end

  get api_v1_test_module_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :id, 'Test module id', required: true
    let(:id) { @test_module.id }

    example 'Show' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end
  end

  post api_v1_test_plan_test_modules_path(':test_plan_id') do
    header 'Content-Type', 'application/json'

    parameter :test_plan_id, 'ID of test plan', required: true
    let(:test_plan_id) { @test_plan.id }

    before do
      @test_module_for_create = build(:test_module)
    end

    parameter :test_module, 'Test module attributes'
    with_options scope: :test_module do
      parameter :title, 'Title of the test module', required: true
      parameter :description, 'Description of the test module'
      parameter :parent_id, 'Id of parent test module. If you give this parameter, this test module will be nested in parent test module'
    end

    let(:test_module) do
      {
        title: @test_module_for_create.title,
        description: @test_module_for_create.description
      }
    end
    let(:raw_post) { params.to_json }

    example 'Create' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)
      content = JSON.parse(response_body).slice('title', 'description')

      expect(status).to be 200
      expect(content).to eq(@test_module_for_create.attributes.slice('title', 'description'))
    end

    example 'Create. Not tester or higher rank' do
      do_request(auth_token: @developer.authenticity_tokens.last.token)

      expect(status).to be 403
    end
  end

  put api_v1_test_module_path(':id') do
    header 'Content-Type', 'application/json'

    before do
      @test_module_for_update = create(:test_module, test_plan_id: @test_plan.id, created_by: @owner.id)
    end

    parameter :id, 'Test module id', required: true
    parameter :test_module, 'Test module attributes'

    with_options scope: :test_module do
      parameter :title, 'Title of the test module'
      parameter :description, 'Description of the test module'
      parameter :parent_id, 'Id of parent test module. If you give this parameter, this test module will be nested in parent test module'
    end

    let(:id) { @test_module_for_update.id }
    let(:test_module) do
      {
        title: @test_module_for_update.title,
        description: @test_module_for_update.description
      }
    end
    let(:raw_post) { params.to_json }

    example 'Update' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end

    example 'Update. Not tester or higher rank' do
      do_request(auth_token: @developer.authenticity_tokens.last.token)

      expect(status).to be 403
    end
  end

  delete api_v1_test_module_path(':id') do
    header 'Content-Type', 'application/json'

    before do
      @test_module_for_delete = create(:test_module, test_plan_id: @test_plan.id, created_by: @owner.id)
    end

    parameter :id, 'Test module id', required: true

    let(:id) { @test_module_for_delete.id }
    let(:raw_post) { params.to_json }

    example 'Delete' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end

    example 'Delete. Not tester or higher rank' do
      do_request(auth_token: @developer.authenticity_tokens.last.token)

      expect(status).to be 403
    end
  end
end
