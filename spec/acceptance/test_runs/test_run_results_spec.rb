require 'acceptance_helper'

resource 'Test Run Results' do
  before :all do
    set_variables_for_api
    @test_plan = create(:setup_test_plan, project_id: @project.id, created_by: @owner.id)
    @second_test_plan = create(:setup_test_plan, project_id: @project.id, created_by: @owner.id)
    @test_run = create(
      :test_run,
      project_id: @project.id, reporter_id: @owner.id,
      assigner_id: @owner.id, test_run_results_attributes: [{ test_plan_id: @test_plan.id }]
    )
  end

  parameter :auth_token, 'User authenticity token', required: true
  parameter :token, 'Uniq project token', required: true

  let(:token) { @project.token }

  get api_v1_test_run_test_run_results_path(':test_run_id') do
    header 'Content-Type', 'application/json'

    parameter :test_run_id, 'ID of test run', required: true
    let(:test_run_id) { @test_run.id }

    example 'Index' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      status.should == 200
    end

    example 'Index. User not project member' do
      do_request(auth_token: @not_project_member.authenticity_tokens.last.token)
      status.should == 403
    end
  end

  get api_v1_test_run_result_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :id, 'Test run result id', required: true
    let(:id) { @test_run.test_run_results.first.id }

    example 'Show' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      status.should == 200 && response_body.should == @test_run.test_run_results.first.to_json
    end
  end

  put api_v1_test_run_result_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :id, 'Test run result id', required: true
    parameter :test_run_result, 'Test run result attributes'
    with_options scope: :test_run_result do
      parameter :test_case_id, 'Test case id'
      parameter :result_status, 'Status of test run results, might be in "pass", "block", "untested" and "fail"'
    end

    let(:id) { @test_run.test_run_results.second.id }
    let(:test_run_result) { { result_status: 'pass' } }
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

  delete api_v1_test_run_result_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :id, 'Test run result id', required: true

    let(:id) { @test_run.test_run_results.last.id }
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
