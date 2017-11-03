require 'acceptance_helper'

resource 'Test Plans' do
  before :all do
    set_variables_for_api
    5.times { create(:test_plan, project_id: @project.id, created_by: @owner.id) }
    @test_plan = create(:test_plan, project_id: @project.id, created_by: @owner.id)
  end

  parameter :auth_token, 'User authenticity token', required: true
  parameter :token, 'Uniq project token', required: true

  let(:token) { @project.token }

  get api_v1_test_plans_path do
    header 'Content-Type', 'application/json'

    example 'Index' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      status.should == 200
    end

    example 'Index. User not project member' do
      do_request(auth_token: @not_project_member.authenticity_tokens.last.token)
      status.should == 403
    end
  end

  get api_v1_test_plan_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :id, 'Test plan id', required: true
    let(:id) { @test_plan.id }

    example 'Show' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      status.should == 200 && response_body.should == @test_plan.to_json
    end
  end

  post api_v1_test_plans_path do
    header 'Content-Type', 'application/json'

    before do
      @test_plan_for_create = build(:test_plan)
    end

    parameter :test_plan, 'Test plan attributes', required: true
    with_options scope: :test_plan do
      parameter :title, 'Title of the test plan', required: true
      parameter :description, 'Description of the test plan'
    end

    let(:test_plan) do
      {
        title: @test_plan_for_create.title,
        description: @test_plan_for_create.description
      }
    end
    let(:raw_post) { params.to_json }

    example 'Create' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)
      content = JSON.parse(response_body).slice('title', 'description')

      expect(status).to be 200
      expect(content).to eq(@test_plan_for_create.attributes.slice('title', 'description'))
    end

    example 'Create. Not tester or higher rank' do
      do_request(auth_token: @developer.authenticity_tokens.last.token)

      expect(status).to be 403
    end
  end

  put api_v1_test_plan_path(':id') do
    header 'Content-Type', 'application/json'

    before do
      @test_plan_for_update = create(:test_plan, project_id: @project.id, created_by: @owner.id)
    end

    parameter :id, 'Test plan id', required: true
    parameter :test_plan, 'Test plan attributes'

    with_options scope: :test_plan do
      parameter :title, 'Title of the test plan'
      parameter :description, 'Description of the test plan'
    end

    let(:id) { @test_plan_for_update.id }
    let(:test_plan) do
      {
        title: @test_plan_for_update.title,
        description: @test_plan_for_update.description
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

  delete api_v1_test_plan_path(':id') do
    header 'Content-Type', 'application/json'

    before do
      @test_plan_for_delete = create(:test_plan, project_id: @project.id, created_by: @owner.id)
    end

    parameter :id, 'Test plan id', required: true

    let(:id) { @test_plan_for_delete.id }
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
