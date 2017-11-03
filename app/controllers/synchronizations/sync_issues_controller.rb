module Synchronizations
  class SyncIssuesController < SynchronizationsController
    skip_before_action :set_plugin_name

    def new
      @settings = @project.plugin_settings
      modal_show params: {
        parent_controller: :issues,
        parent_url: issues_path(@project)
      }
    end

    def create
      setting_params = plugin_settings_params
      return head :unprocessable_entity if setting_params.nil?

      @job_id = SyncIssueWorker.perform_async(
        setting_params.values.map(&:to_h),
        @project.id,
        current_user.id
      )
      @container = SidekiqStatus::Container.load(@job_id)
    end
  end
end
