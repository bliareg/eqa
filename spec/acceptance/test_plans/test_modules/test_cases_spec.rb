require 'acceptance_helper'

resource 'Test Cases' do
  before :all do
    set_variables_for_api
    @test_plan = create(:test_plan, project_id: @project.id, created_by: @owner.id)
    @test_module = create(:test_module, test_plan_id: @test_plan.id, created_by: @owner.id)
    5.times do
      create(
        :test_case,
        test_plan_id: @test_plan.id, module_id: @test_module.id, created_by: @owner.id
      )
    end
    @test_case = create(
      :test_case,
      test_plan_id: @test_plan.id, module_id: @test_module.id, created_by: @owner.id
    )
  end

  parameter :auth_token, 'User authenticity token', required: true
  parameter :token, 'Uniq project token', required: true

  let(:token) { @project.token }

  get api_v1_test_cases_path(':parent_name', ':parent_id') do
    header 'Content-Type', 'application/json'

    parameter :parent_name, 'Can be "test_plan" or "test_module"', required: true
    parameter :parent_id, 'Id of the parent', required: true

    example 'Index in test modules' do
      do_request(
        auth_token: @owner.authenticity_tokens.last.token,
        parent_id:  @test_module.id,
        parent_name: :test_module
      )

      status.should == 200
    end

    example 'Index in test plans' do
      do_request(
        auth_token: @owner.authenticity_tokens.last.token,
        parent_id:  @test_plan.id,
        parent_name: :test_plan
      )

      status.should == 200
    end

    example 'Index. User not project member' do
      do_request(auth_token: @not_project_member.authenticity_tokens.last.token)
      status.should == 403
    end
  end

  get api_v1_test_case_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :id, 'Test case ID', required: true
    let(:id) { @test_case.id }

    example 'Show' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end
  end

  post api_v1_test_module_test_cases_path(':test_module_id') do
    header 'Content-Type', 'application/json'

    parameter :test_module_id, 'Test module ID', required: true
    let(:test_module_id) { @test_module.id }

    before do
      @test_case_for_create = attributes_for(:test_case)
    end

    parameter :test_case, 'Test case attributes', required: true
    with_options scope: :test_case do
      parameter :title, 'Title of the test case', required: true
      parameter :pre_steps, 'Pre steps to test case'
      parameter :steps, 'Steps to test case'
      parameter :expected_result, 'Expected test case result'
      parameter :case_type, 'Type of test case'
    end

    let(:test_case) { @test_case_for_create }
    let(:raw_post) { params.to_json }

    example 'Create' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end

    example 'Create. Not tester or higher rank' do
      do_request(auth_token: @developer.authenticity_tokens.last.token)

      expect(status).to be 403
    end
  end

  put api_v1_test_case_path(':id') do
    header 'Content-Type', 'application/json'

    before do
      @test_case_for_update = create(
        :test_case,
        test_plan_id: @test_plan.id, module_id: @test_module.id, created_by: @owner.id
      )
    end

    parameter :id, 'Test case id', required: true

    parameter :test_case, 'Test case attributes'
    with_options scope: :test_case do
      parameter :title, 'Title of the test case'
      parameter :pre_steps, 'Pre steps to test case'
      parameter :steps, 'Steps to test case'
      parameter :expected_result, 'Expected test case result'
      parameter :case_type, 'Type of test case'
    end

    let(:id) { @test_case_for_update.id }
    let(:test_case) { attributes_for(:test_case) }
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

  delete api_v1_test_case_path(':id') do
    header 'Content-Type', 'application/json'

    before do
      @test_case_for_delete = create(
        :test_case,
        test_plan_id: @test_plan.id, module_id: @test_module.id, created_by: @owner.id
      )
    end

    parameter :id, 'Test case id', required: true

    let(:id) { @test_case_for_delete.id }
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
