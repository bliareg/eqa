require 'rails_helper'
require_relative 'feature_helper'

feature 'Issues page' do
  before :all do
    user = create(:user)
    login_as user, scope: :user
    organization = create(:organization)
    Role.create(organization_id: organization.id,
                user_id: user.id,
                project_id: nil,
                role: 0)
    project = create(:project, organization: organization, owner: user)
    Role.create(organization_id: organization.id,
                user_id: user.id,
                project_id: project.id,
                role: :owner)
    visit issues_path(project.id)
  end

  scenario 'checking synchronize link' do
    expect(page).to have_content 'Synchronize'
  end
end
