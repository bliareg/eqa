require 'acceptance_helper'

resource 'Issues' do
  before :all do
    set_variables_for_api
    @owner.authenticity_tokens << build(:authenticity_token)
    @issue = create(:issue, reporter_id: @owner, assigner_id: @developer, project_id: @project.id)
    create(:web, user_id: @owner.id, project_id: @project.id)
    create(:apk_build, user_id: @owner.id, project_id: @project.id)
  end
  parameter :token, 'Uniq project token', required: true

  let(:token) { @project.token }

  post '/api/v1/projects/issue_info' do
    header 'Content-Type', 'application/json'

    parameter :auth_token, 'User authenticity token'

    let(:auth_token) { @owner.authenticity_tokens.last.token }

    before :all do
      @identeficators = @project.test_objects.last.identeficator.split(':')
    end

    parameter :packageName,      'Application package name', required: true
    parameter :buildVersionCode, 'Application version code', required: true
    parameter :buildVersionName, 'Application version name', required: true

    let(:packageName) { @identeficators[0] }
    let(:buildVersionCode) { @identeficators[1] }
    let(:buildVersionName) { @identeficators[2] }

    let(:raw_post) { params.to_json }
    example 'Issue info with mobile build' do
      do_request

      status.should == 200
    end
  end

  post '/api/v1/projects/issue_info' do
    header 'Content-Type', 'application/json'
    parameter :auth_token, 'User authenticity token'

    let(:auth_token) { @owner.authenticity_tokens.last.token }

    before :all do
      @link = @project.test_objects.first.link
    end

    parameter :link, 'Link to your website', required: true

    let(:link) { @link }

    let(:raw_post) { params.to_json }
    example 'Issue info with web site' do
      do_request

      status.should == 200
    end
  end

  post '/api/v1/projects/issues/create' do
    header 'Content-Type', 'multipart/form-data'

    parameter :auth_token, 'User authenticity token'

    let(:auth_token) { @owner.authenticity_tokens.last.token }

    before :all do
      @issue = create(:issue, project_id: @project.id,
                              reporter_id: @owner.id,
                              assigner_id: @developer.id)
      @image = create(:jpg_image, attachable: @issue).file
      @video = create(:mp4_video, attachable: @issue).file
    end

    with_options required: true do
      parameter :summary,        'Issue summary'
      parameter :deviceSerial,   'Serial device number'
      parameter :deviceModel,    'Model of device'
      parameter :osVersion,      'Device system version'
      parameter :test_object_id, 'ID test object on site'
    end

    parameter :device,             'Device version'
    parameter :deviceBrand,        'Brand of device'
    parameter :deviceManufacturer, 'Manufacturer of device'

    parameter :description,     'Issue description'
    parameter :issue_type,      'Type of issue'
    parameter :priority,        'Issue priority'
    parameter :assigner_id,     'Issue assigner ID'
    parameter 'test.jpg',
              'Name your upload image. Data type must be "jpg".',
              'Type' => 'Multipart/Form-data'
    parameter 'test.mp4',
              'Name your upload video. Data type must be "mp4".',
              'Type' => 'Multipart/Form-data'

    let(:summary)            { @issue.summary                 }
    let(:description)        { @issue.description             }
    let(:issue_type)         { @issue.issue_type              }
    let(:priority)           { @issue.priority                }
    let(:assigner_id)        { @developer.id                  }
    let(:test_object_id)     { @project.test_objects.first.id }
    let(:devise)             { 'vbox86p'                      }
    let(:deviceBrand)        { 'Android'                      }
    let(:deviceManufacturer) { 'Genymotion'                   }
    let(:deviceModel)        { 'Nexus 5X API 23'              }
    let(:deviceSerial)       { '1234567'                      }
    let(:osVersion)          { '7.0'                          }
    let('test.jpg') { Rack::Test::UploadedFile.new(@image.path, @image.content_type) }
    let('test.mp4') { Rack::Test::UploadedFile.new(@video.path, @video.content_type) }

    example 'Create. From devise' do
      do_request

      status.should == 200
    end
  end

  post '/api/v1/projects/issues/create' do
    header 'Content-Type', 'multipart/form-data'

    before :all do
      @image = create(:jpg_image, attachable: @issue).file
      @video = create(:mp4_video, attachable: @issue).file
    end

    with_options required: true do
      parameter :auth_token, 'User authenticity token'
      parameter :summary,    'Issue summary'
    end

    parameter :test_object_id, 'ID test object on site'
    parameter :description,    'Issue description'
    parameter :issue_type,     'Type of issue'
    parameter :priority,       'Issue priority'
    parameter :assigner_id,    'Issue assigner ID'
    parameter 'test.jpg',
              'Name your upload image. Data type must be "jpg".',
              'Type' => 'Multipart/Form-data'
    parameter 'test.mp4',
              'Name your upload video. Data type must be "mp4".',
              'Type' => 'Multipart/Form-data'

    let(:summary)        { @issue.summary                 }
    let(:description)    { @issue.description             }
    let(:issue_type)     { @issue.issue_type              }
    let(:priority)       { @issue.priority                }
    let(:assigner_id)    { @developer.id                  }
    let(:test_object_id) { @project.test_objects.first.id }
    let('test.jpg')      { Rack::Test::UploadedFile.new(@image.path, @image.content_type) }
    let('test.mp4')      { Rack::Test::UploadedFile.new(@video.path, @video.content_type) }
    let(:auth_token)     { @owner.authenticity_tokens.last.token }

    example 'Create' do
      do_request

      status.should == 200
    end
  end

  get api_v1_issue_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :auth_token, 'User authenticity token', required: true
    parameter :id, 'Issue ID', required: true
    let(:id)         { @issue.id }
    let(:auth_token) { @owner.authenticity_tokens.last.token }
    let(:raw_post)   { params.to_json }

    example 'Show from id' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end
  end

  get api_v1_issue_path(':id') do
    header 'Content-Type', 'application/json'

    parameter :auth_token, 'User authenticity token', required: true
    parameter :id, 'Issue ID in project', required: true
    let(:id) { 'pid' + @issue.project_issue_number.to_s }
    let(:auth_token) { @owner.authenticity_tokens.last.token }
    let(:raw_post)   { params.to_json }

    example 'Show from id in project ' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end
  end

  get api_v1_issues_path do
    header 'Content-Type', 'application/json'
    parameter :auth_token, 'User authenticity token', required: true
    let(:auth_token)     { @owner.authenticity_tokens.last.token }

    example 'Index' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      status.should == 200
    end

    example 'Index. User not project member' do
      do_request(auth_token: @not_project_member.authenticity_tokens.last.token)
      status.should == 403
    end
  end

  put api_v1_issue_path(':id') do
    header 'Content-Type', 'multipart/form-data'

    before do
      @issue_for_update = create(
        :issue, reporter_id: @owner, assigner_id: @developer, project_id: @project.id
      )
      @image = create(:jpg_image, attachable: @issue).file
      @video = create(:mp4_video, attachable: @issue).file
    end

    parameter :id, 'Issue ID', required: true
    parameter :auth_token, 'User authenticity token', required: true

    parameter :summary,        'Issue summary'
    parameter :test_object_id, 'ID test object on site'
    parameter :description,    'Issue description'
    parameter :issue_type,     'Type of issue'
    parameter :priority,       'Issue priority'
    parameter :status_id,      'Status ID'
    parameter :assigner_id,    'Issue assigner ID'
    parameter 'test.jpg',
              'Name your upload image. Data type must be "jpg".',
              'Type' => 'Multipart/Form-data'
    parameter 'test.mp4',
              'Name your upload video. Data type must be "mp4".',
              'Type' => 'Multipart/Form-data'

    let(:id)             { @issue_for_update.id }
    let(:summary)        { @issue.summary                 }
    let(:description)    { @issue.description             }
    let(:issue_type)     { @issue.issue_type              }
    let(:priority)       { @issue.priority                }
    let(:assigner_id)    { @developer.id                  }
    let(:status_id)      { Status.all.ids.sample          }
    let(:test_object_id) { @project.test_objects.first.id }
    let('test.jpg')      { Rack::Test::UploadedFile.new(@image.path, @image.content_type) }
    let('test.mp4')      { Rack::Test::UploadedFile.new(@video.path, @video.content_type) }
    let(:auth_token)     { @owner.authenticity_tokens.last.token }

    example 'Update from id' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end
  end

  put api_v1_issue_path(':id') do
    header 'Content-Type', 'multipart/form-data'

    before do
      @issue_for_update = create(
        :issue, reporter_id: @owner, assigner_id: @developer, project_id: @project.id
      )
      @image = create(:jpg_image, attachable: @issue).file
      @video = create(:mp4_video, attachable: @issue).file
    end

    parameter :id, 'Issue ID in project', required: true
    parameter :auth_token, 'User authenticity token', required: true

    parameter :summary,        'Issue summary'
    parameter :test_object_id, 'ID test object on site'
    parameter :description,    'Issue description'
    parameter :issue_type,     'Type of issue'
    parameter :priority,       'Issue priority'
    parameter :status_id,      'Status ID'
    parameter :assigner_id,    'Issue assigner ID'
    parameter 'test.jpg',
              'Name your upload image. Data type must be "jpg".',
              'Type' => 'Multipart/Form-data'
    parameter 'test.mp4',
              'Name your upload video. Data type must be "mp4".',
              'Type' => 'Multipart/Form-data'

    let(:id)             { 'pid' + @issue_for_update.project_issue_number.to_s }
    let(:summary)        { @issue.summary                 }
    let(:description)    { @issue.description             }
    let(:issue_type)     { @issue.issue_type              }
    let(:priority)       { @issue.priority                }
    let(:assigner_id)    { @developer.id                  }
    let(:status_id)      { Status.all.ids.sample          }
    let(:test_object_id) { @project.test_objects.first.id }
    let('test.jpg')      { Rack::Test::UploadedFile.new(@image.path, @image.content_type) }
    let('test.mp4')      { Rack::Test::UploadedFile.new(@video.path, @video.content_type) }
    let(:auth_token)     { @owner.authenticity_tokens.last.token }

    example 'Update from id in project' do
      do_request(auth_token: @owner.authenticity_tokens.last.token)

      expect(status).to be 200
    end
  end

  delete api_v1_issue_path(':id') do
    header 'Content-Type', 'application/json'

    before do
      @issue_for_delete = create(
        :issue, reporter_id: @owner, assigner_id: @developer, project_id: @project.id
      )
    end

    parameter :id, 'Issue ID', required: true
    parameter :auth_token, 'User authenticity token', required: true

    let(:id)         { @issue_for_delete.id }
    let(:auth_token) { @owner.authenticity_tokens.last.token }
    let(:raw_post) { params.to_json }

    example 'Delete from ID' do
      do_request

      expect(status).to be 200
    end
  end

  delete api_v1_issue_path(':id') do
    header 'Content-Type', 'application/json'

    before do
      @issue_for_delete = create(
        :issue, reporter_id: @owner, assigner_id: @developer, project_id: @project.id
      )
    end

    parameter :id, 'Issue ID in project', required: true
    parameter :auth_token, 'User authenticity token', required: true

    let(:id) { 'pid' + @issue_for_delete.project_issue_number.to_s }
    let(:auth_token) { @owner.authenticity_tokens.last.token }
    let(:raw_post) { params.to_json }

    example 'Delete from ID in project' do
      do_request

      expect(status).to be 200
    end
  end
end
