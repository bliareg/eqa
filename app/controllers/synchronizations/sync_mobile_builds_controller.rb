module Synchronizations
  class SyncMobileBuildsController < SynchronizationsController
    SETTING_FILER = 'git'.freeze

    skip_before_action :set_plugin_name

    def new
      @settings = @project.plugin_settings(SETTING_FILER)
      modal_show params: {
        parent_controller: 'Projects::TestObjects',
        parent_url: project_test_objects_path(@project)
      }
    end

    def create
      setting_params = plugin_settings_params
      return head :unprocessable_entity if setting_params.nil?

      @job_id = GetServiceBuildWorker.perform_async(
        setting_params.values.map(&:to_h),
        @project.id,
        current_user.id
      )
    end
  end
end
