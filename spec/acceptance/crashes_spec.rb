require 'acceptance_helper'

resource 'Crashes' do
  before :all do
    set_variables_for_api
    create(:apk_build, user_id: @owner.id, project_id: @project.id)
  end

  post '/projects/upload_crashes' do
    header 'Content-Type', 'application/json'

    before do
      @identeficators = @project.test_objects.first.identeficator.split(':')
    end

    with_options required: true do
      parameter :token,            'Uniq project token'
      parameter :packageName,      'Application package name'
      parameter :buildVersionCode, 'Application version code'
      parameter :buildVersionName, 'Application version name'
      parameter :deviceSerial,       'Serial device number'
      parameter :deviceModel,        'Model of device'
      parameter :osVersion,          'Device system version'
    end

    parameter :crashesData, 'Data of crashes'

    with_options scope: :crashesData do
      parameter :createdAt,        'Date of created log file in timestamp'
      parameter :fileName,         'Name log file'
      parameter :logFile,          'Log file in base 64 encoding'
    end

    parameter :device,             'Device version'
    parameter :deviceBrand,        'Brand of device'
    parameter :deviceManufacturer, 'Manufacturer of device'

    let(:token)              { @project.token     }
    let(:packageName)        { @identeficators[0] }
    let(:buildVersionCode)   { @identeficators[1] }
    let(:buildVersionName)   { @identeficators[2] }
    let(:devise)             { 'vbox86p'          }
    let(:deviceBrand)        { 'Android'          }
    let(:deviceManufacturer) { 'Genymotion'       }
    let(:deviceModel)        { 'Nexus 5X API 23'  }
    let(:deviceSerial)       { '1234567'          }
    let(:osVersion)          { '7.0'              }
    let(:crashesData) do
      [
        {
          createdAt: '1473334063084',
          fileName: 'Android-test-log.txt',
          logFile: "H4sIAAAAAAAAAJ1STU8CMRA966/ogcOamIaVRYTbZl0DiYBuxIO3oTvuFrrt2hYi/95C+QiIieE0\n09d5r/NeOoMlUAGyoNlCWl5h+s2wtlzJHklfBglJs2yckXGSTLIsfbwl/fg9JU+T0fUVWMJURW3J\n5bxSUy7QUJC5VjynCGb1BTRmli+5XaXu+BpT1Frp4AScuQ167fDmEkFgDI1pRM3mWdWwdYlqI6R6\nIc8KRpEX3PGVoX3XC9S03NQEhJgCmwc7eEPrtLp/8nJuarCsHDojUOAxsdv+xXtWqnbXwpVg23uv\n0cPxLNT13thbqRFyWgE/+NpiPv4o7Hj2bP8fNH4KZJYO0ZYqp1wu1RyDETg2Eg8e0t09yqVFLUGs\nN/1YFcriQHLb8OOxzGNdmHVGbut1xoeRbVB39//V9GZOBe5DJ/ADXWh+4tQCAAA=\n"
        }
      ]
    end

    let(:raw_post) { params.to_json }
    example 'Upload crashes' do
      do_request

      status.should == 200
    end
  end
end
