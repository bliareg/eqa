require 'acceptance_helper'

resource 'Test Runs' do
  before :all do
    set_variables_for_api
    @test_plan = create(:setup_test_plan, project_id: @project.id, created_by: @owner.id)
    5.times do
      create(
        :test_run,
        project_id: @project.id, reporter_id: @owner.id,
        assigner_id: @owner.id
      )
    end
    @test_run = create(
      :test_run,
      project_id: @project.id, reporter_id: @owner.id,
      assigner_id: @owner.id, test_run_results_attributes: [{ test_plan_id: @test_plan.id }]
    )
  end

  parameter :auth_token, 'User authenticity token', required: true
  parameter :token, 'Uniq project token', required: true

  let(:token) { @project.token }

  get api_v1_test_runs_path do
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

  get api_v1_test_run_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :id, 'Test run id', required: true
    let(:id) { @test_run.id }

    example 'Show' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      status.should == 200 && response_body.should == @test_run.to_json
    end
  end

  post api_v1_test_runs_path do
    header 'Content-Type', 'application/json'

    before do
      @test_run_for_create = attributes_for(
        :test_run, assigner_id: @owner.id
      )
    end

    parameter :test_run, 'Test run attributes', required: true
    with_options scope: :test_run do
      parameter :title, 'Title of the test plan', required: true
      parameter :assigner_id, 'ID of assigner', required: true
      parameter :description, 'Description of the test plan'
      parameter :test_run_results_attributes, 'Attributes of test cases. If you want include they to this test run'

      with_options scope: :test_run_results_attributes do
        parameter :test_plan_id, 'If you send this parameter, all cases in this test plan was automaticlly added to this test run'
        parameter :test_case_id, 'Id of test cases, which you want to add'
        parameter :id, 'Id of test run result. Send this with parameter _destroy: true, if you want destroy this result for test case'
        parameter :_destroy, 'remove result with existing id. Set this parameter to true'
      end
    end

    let(:test_run) do
      @test_run_for_create.merge(
        test_run_results_attributes: [{ test_plan_id: @test_plan.id }]
      )
    end
    let(:raw_post) { params.to_json }

    example 'Create' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)
      content = JSON.parse(response_body)

      expect(status).to be 200
      expect(content['description']).to eq(@test_run_for_create[:description])
      expect(content['title']).to eq(@test_run_for_create[:title])
    end

    example 'Create. Not tester or higher rank' do
      do_request(auth_token: @developer.authenticity_tokens.last.token)

      expect(status).to be 403
    end
  end

  put api_v1_test_run_path(':id') do
    header 'Content-Type', 'application/json'

    before do
      @attr_for_update = attributes_for(:test_run)
    end

    parameter :id, 'Test run id', required: true
    parameter :test_run, 'Test run attributes'
    with_options scope: :test_run do
      parameter :title, 'Title of the test plan'
      parameter :description, 'Description of the test plan'

      parameter :test_run_results_attributes, 'Attributes of test cases. If you want include they to this test run'
      with_options scope: [:test_run, :test_run_results_attributes] do
        parameter :test_plan_id, 'If you send this parameter, all cases in this test plan was automaticlly added to this test run'
        parameter :test_case_id, 'Id of test cases, which you want to add'
        parameter :id, 'Id of test run result. Send this with parameter _destroy: true, if you want destroy this result for test case'
        parameter :_destroy, 'remove result with existing id. Set this parameter to true'
      end
    end

    let(:id) { @test_run.id }

    let(:test_run) do
      {
        title: @attr_for_update[:title],
        description: @attr_for_update[:description]
      }
    end

    let(:raw_post) { params.to_json }

    example 'Update test run with destroy test run result' do
      do_request(
        auth_token: @owner.authenticity_tokens.last.token,
        test_run: {
          test_run_results_attributes: [{ id: @test_run.test_run_results.first.id, _destroy: true }]
        }
      )

      expect(status).to be 200
    end

    example 'Update test run with create test run result' do
      test_case = @test_plan.test_cases.create(
        attributes_for(:test_case, module_id: @test_plan.test_modules.first.id)
      )
      do_request(
        auth_token: @owner.authenticity_tokens.last.token,
        test_run: {
          test_run_results_attributes: [{ test_case_id: test_case.id }]
        }
      )

      expect(status).to be 200
    end

    example 'Update. Not tester or higher rank' do
      do_request(auth_token: @developer.authenticity_tokens.last.token)

      expect(status).to be 403
    end
  end

  delete api_v1_test_run_path(':id') do
    header 'Content-Type', 'application/json'

    before do
      @test_run_for_delete = create(
        :test_run, assigner_id: @owner.id, project_id: @project.id
      )
    end

    parameter :id, 'Test run id', required: true

    let(:id) { @test_run_for_delete.id }
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
