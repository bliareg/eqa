module SpecHelpers
  def check_organization_raw(organization)
    expect(page).to have_content organization.title
    expect(page).to have_content organization.created_at.strftime('%d/%m/%Y')
    expect(page).to have_content organization.owner.name
    expect(page).to have_content 'Projects'
    expect(page).to have_content organization.projects.count.to_s
    expect(page).to have_content 'Employees'
    expect(page).to have_content organization.employees_count.to_s
  end

  def check_logged_header
    expect(page).to have_content I18n.t('users.my_organizations')
    expect(page).to have_content I18n.t('users.my_projects')
    expect(page).to have_content I18n.t('add_organization')
    expect(page).to have_content I18n.t('add_project')
    expect(page).to have_content I18n.t('users.profile')
  end

  def check_organization_info(organization)
    expect(page).to have_content organization.title
    expect(page).to have_content 'Created At'
    expect(page).to have_content organization.created_at.strftime('%d/%m/%Y')
    expect(page).to have_content 'Created By'
    expect(page).to have_content organization.owner.name
    expect(page).to have_content 'Projects'
    expect(page).to have_content organization.projects.count.to_s
    expect(page).to have_content 'Members'
    expect(page).to have_content organization.employees_count.to_s
    expect(page).to have_content 'Current plan'
  end

  def check_member_static_content
    expect(page).to have_content(I18n.t('member_name'))
    expect(page).to have_content(I18n.t('total'))
    expect(page).to have_content(I18n.t('projects'))
    expect(page).to have_content(I18n.t('joined_at'))
    expect(page).to have_content(I18n.t('organization.role'))
  end

  def check_members_title_and_button
    expect(page).to have_content(I18n.t('organization.members'))
  end

  def setup_statuses
    all_statuses = Status.pluck(:name)
    Status::DEFAULT_STATUSES.each_value do |params_status|
      Status.create(name: params_status[:name]) unless all_statuses.include?(params_status[:name])
    end
  end
end
