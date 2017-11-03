module Projects
  module TestObjectsHelper
    def download_build_links
      link_to(root_url + @test_object.file.url,
              @test_object.url,
              class: 'btn-white-green link-to-object',
              target: '_blank')
    end

    def calculate_size_in_mb(file)
      float = file.size.to_f / 100_000
      float = float.round.to_f / 10
      float.to_s + ' MB'
    end

    def destroy_test_object_button(test_object)
      return unless current_user.manager_or_higher_rank?(current_user.id, @project.id)
      link_to test_object_path(test_object.id), method: :delete, remote: true,
                                                data: { confirm: t('are_you_sure') },
                                                class: 'ico-delete' do
        content_tag(:span, '', class: 'icon-delete-icon')
      end
    end

    def get_build_button
      btn_classes = 'btn btn-green synchronize_plugin inactive'
      btn_path = project_sync_mobile_builds_path(@project)
      if @settings.empty?
        button_tag(class: btn_classes, disabled: true, path: btn_path) do
          t('get_build').html_safe +
            content_tag(:span, t('no_plugins_for_build'), class: 'hover-block')
        end
      else
        button_tag(t('get_build'), class: btn_classes, disabled: true, path: btn_path)
      end
    end

    def chevron_for(test_object)
      if test_object.file_file_name.present?
        '<td class="chevron"><span class="chevron-down"></span></td>'.html_safe
      else
        '<td></td>'.html_safe
      end
    end

    def link_add_test_object(project, options = nil)
      return unless authorize_to_view_links?(project)
      link_to t('add_test_object'),
              new_project_test_object_path(project, page: request.path[/(?<=\/)\w*$/]),
              class: "btn btn-green #{options}",
              remote: true
    end

    def link_get_test_object(project)
      return unless authorize_to_view_links?(project)
      link_to(t('get_test_object'),
              new_project_sync_mobile_build_path(@project),
              remote: true,
              class: 'btn btn-green')
    end

    private

    def authorize_to_view_links?(project)
      policy_obj = policy(project)
      policy_obj.member? && !policy_obj.tester_or_viewer?
    end
  end
end
