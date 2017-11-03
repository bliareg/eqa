module PresentersShareable
  def user_role(current_user)
    search_string = 'user_id = :user_id'
    if self.is_a?(ProjectPresenter)
      search_string << ' AND project_id = :object_id'
    else
      search_string << ' AND organization_id = :object_id'
    end
    role = Role.where(search_string,
                      object_id: self.id, user_id: view_context.current_user.id).take
    role ? role.role_text : ''
  end
end
