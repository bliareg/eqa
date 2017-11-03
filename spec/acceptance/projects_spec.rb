require 'acceptance_helper'

resource 'Projects' do
  before :all do
    set_variables_for_api
    5.times { create(:project, user_id: @owner.id) }
  end

  parameter :auth_token, 'User authenticity token', required: true

  get api_v1_projects_path do
    header 'Content-Type', 'application/json'

    example 'Index' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      status.should == 200
    end
  end

  get api_v1_project_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :id, 'Project id', required: true
    let(:id) { @project.id }

    example 'Show' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      status.should == 200 && response_body.should == @project.to_json
    end
  end

  post api_v1_projects_path do
    header 'Content-Type', 'application/json'

    before :all do
      @project_for_create = { title: 'Example project' }
    end

    parameter :organization_id, 'Organization id', required: true
    parameter :project, 'Project attributes', required: true
    with_options scope: :project do
      parameter :title, 'Title of the project', required: true
    end

    let(:organization_id) { @organization.id }
    let(:project) { @project_for_create }
    let(:raw_post) { params.to_json }

    example 'Create' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end

    example 'Create. Not owner or admin' do
      do_request(auth_token: @developer.authenticity_tokens.last.token)

      expect(status).to be 403
    end
  end

  put api_v1_project_path(':id') do
    header 'Content-Type', 'application/json'

    before :all do
      @project_for_update = create(:project, user_id: @owner.id, organization_id: @organization.id)
    end

    parameter :id, 'Project id', required: true

    parameter :project, 'Project attributes'
    with_options scope: :project do
      parameter :title, 'Title of the project'
    end

    let(:id) { @project_for_update.id }
    let(:project) do
      {
        title: @project_for_update.title
      }
    end
    let(:raw_post) { params.to_json }

    example 'Update' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end

    example 'Update. Not project manager or higher rank' do
      do_request(auth_token: @developer.authenticity_tokens.last.token)

      expect(status).to be 403
    end
  end

  delete api_v1_project_path(':id') do
    header 'Content-Type', 'application/json'

    before do
      @project_for_delete = create(:project, user_id: @owner.id, organization_id: @organization.id)
    end

    parameter :id, 'Project id', required: true

    let(:id) { @project_for_delete.id }
    let(:raw_post) { params.to_json }

    example 'Delete' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end

    example 'Delete. Not project manager or higher rank' do
      do_request(auth_token: @developer.authenticity_tokens.last.token)

      expect(status).to be 403
    end
  end
end
