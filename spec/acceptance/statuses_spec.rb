require 'acceptance_helper'

resource 'Statuses' do
  before :all do
    set_variables_for_api
    5.times { create(:status, project_id: @project.id) }
  end

  parameter :auth_token, 'User authenticity token', required: true
  parameter :token, 'Uniq project token', required: true

  let(:token) { @project.token }

  get api_v1_statuses_path do
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

  get api_v1_status_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :id, 'Status id', required: true
    let(:id) { Status.first.id }

    example 'Show' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      status.should == 200
    end
  end

  post api_v1_statuses_path do
    header 'Content-Type', 'application/json'

    parameter :status_object, 'Status attributes', required: true
    with_options scope: :status_object do
      parameter :name, 'Status name', required: true
    end

    let(:status_object) { attributes_for(:status) }
    let(:raw_post) { params.to_json }

    example 'Create' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end

    example 'Create. Viewer' do
      do_request(auth_token: @viewer.authenticity_tokens.last.token)

      expect(status).to be 403
    end
  end

  put api_v1_status_path(':id') do
    header 'Content-Type', 'application/json'

    before do
      @status_for_update = create(:status, project_id: @project.id)
    end

    parameter :id, 'Status id', required: true
    parameter :status_object, 'Status attributes'

    with_options scope: :status_object do
      parameter :name, 'Status name'
    end

    let(:id) { @status_for_update.id }
    let(:status_object) { attributes_for(:status) }
    let(:raw_post) { params.to_json }

    example 'Update' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end

    example 'Update. Viewer' do
      do_request(auth_token: @viewer.authenticity_tokens.last.token)

      expect(status).to be 403
    end
  end

  delete api_v1_status_path(':id') do
    header 'Content-Type', 'application/json'

    before do
      @status_for_delete = create(:status, project_id: @project.id)
    end

    parameter :id, 'Status id', required: true

    let(:id) { @status_for_delete.id }
    let(:raw_post) { params.to_json }

    example 'Delete' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end

    example 'Delete. Viewer' do
      do_request(auth_token: @viewer.authenticity_tokens.last.token)

      expect(status).to be 403
    end
  end
end
