require 'acceptance_helper'

resource 'Issues Attachments' do
  before :all do
    set_variables_for_api
    @owner.authenticity_tokens << build(:authenticity_token)
    @issue = create(:issue, reporter_id: @owner, assigner_id: @developer, project_id: @project.id)
  end
  parameter :token, 'Uniq project token', required: true
  parameter :auth_token, 'User authenticity token', required: true

  let(:token) { @project.token }
  let(:auth_token) { @owner.authenticity_tokens.last.token }

  post api_v1_issue_attachments_path(':issue_id') do
    header 'Content-Type', 'multipart/form-data'

    before do
      @image = create(:jpg_image, attachable: @issue).file
    end

    parameter :attachment, 'Your attachment', 'Type' => 'Multipart/Form-data', required: true
    parameter :issue_id, 'Issue ID', required: true

    let(:attachment) { Rack::Test::UploadedFile.new(@image.path, @image.content_type) }
    let(:issue_id) { @issue.id }

    example 'Create' do
      do_request

      expect(status).to be 201
    end
  end

  post api_v1_issue_attachments_path(':issue_id') do
    header 'Content-Type', 'multipart/form-data'

    before do
      @image = create(:jpg_image, attachable: @issue).file
    end

    parameter :attachment, 'Your attachment', 'Type' => 'Multipart/Form-data', required: true
    parameter :issue_id, 'Issue ID in project', required: true

    let(:attachment) { Rack::Test::UploadedFile.new(@image.path, @image.content_type) }
    let(:issue_id) { 'pid' + @issue.project_issue_number.to_s }

    example 'Create. Id in project' do
      do_request

      expect(status).to be 201
    end
  end

  delete api_v1_attachment_path(':id') do
    header 'Content-Type', 'application/json'

    before do
      @attachment_for_delete =  create(:jpg_image, attachable: @issue)
    end

    parameter :id, 'Attachment ID', required: true

    let(:id)         { @attachment_for_delete.id }
    let(:raw_post) { params.to_json }

    example 'Delete' do
      do_request

      expect(status).to be 200
    end
  end
end
