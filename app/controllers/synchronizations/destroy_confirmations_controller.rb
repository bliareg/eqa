module Synchronizations
  class DestroyConfirmationsController < SynchronizationsController
    before_action :set_synchronization

    def show
      @project = @synchronization.project
      return unless destroy_synchronization_permission?(@synchronization)
      modal_show partial: 'shared/destroy', params: {
        parent_controller: 'Projects::Integrations',
        parent_action_name: :index,
        parent_url: project_integrations_path(@project.slug),
        project_id: @project.slug
      }, locals: locals_hash
    end

    private

    def set_synchronization
      @synchronization = @plugin_name.camelcase
                                     .constantize
                                     .find(params[:synchronization_id])
    end

    def locals_hash
      {
        url:  synchronization_path(@synchronization.name, @synchronization.id),
        text: t('integration') + ' ' + Project::PLUGINS.key(@synchronization.name)
      }
    end
  end
end
