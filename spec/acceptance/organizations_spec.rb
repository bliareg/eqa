require 'acceptance_helper'

resource 'Organizations' do
  before :all do
    set_variables_for_api
    5.times { create(:organization, owner_id: @owner.id) }
  end

  parameter :auth_token, 'User authenticity token', required: true

  get api_v1_organizations_path do
    header 'Content-Type', 'application/json'

    example 'Index' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      status.should == 200
    end
  end

  get api_v1_organization_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :id, 'Organization id', required: true
    let(:id) { @organization.id }

    example 'Show' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      status.should == 200 && response_body.should == @organization.to_json
    end
  end

  post api_v1_organizations_path do
    header 'Content-Type', 'application/json'

    before do
      @organization_for_create = attributes_for(:organization)
    end

    parameter :organization, 'Organization attributes', required: true
    with_options scope: :organization do
      parameter :title, 'Title of the organization', required: true
      parameter :description, 'Description of the organization'
    end

    let(:organization) { @organization_for_create }
    let(:raw_post) { params.to_json }

    example 'Create' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end
  end

  put api_v1_organization_path(':id') do
    header 'Content-Type', 'application/json'

    before :all do
      @organization_for_update = create(:organization, owner_id: @owner.id)
    end

    parameter :id, 'Organization id', required: true

    parameter :organization, 'Organization attributes'
    with_options scope: :organization do
      parameter :title, 'Title of the organization'
      parameter :description, 'Description of the organization'
    end

    let(:id) { @organization_for_update.id }
    let(:organization) do
      {
        title: @organization_for_update.title,
        description: @organization_for_update.description
      }
    end
    let(:raw_post) { params.to_json }

    example 'Update' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end

    example 'Update. Not owner' do
      do_request(auth_token: @developer.authenticity_tokens.last.token)

      expect(status).to be 403
    end
  end

  delete api_v1_organization_path(':id') do
    header 'Content-Type', 'application/json'

    before :all do
      @organization_for_delete = create(:organization, owner_id: @owner.id)
    end

    parameter :id, 'Organization id', required: true

    let(:id) { @organization_for_delete.id }
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
