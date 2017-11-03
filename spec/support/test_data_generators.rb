module TestDataGenerators

  def create_test_data
    @user_2 = create(:user)
    create(:user)
    create(:user)
    create(:user)

    # @org_1
    @org_1 = create(:organization, title: 'Organization_1')
    @org_1.roles << build(:role_owner, user_id: @user.id)
    @org_1.roles << build(:role_admin, user_id: @user_2.id)
    @proj_1 = create(:project, user_id: @user.id, organization_id: @org_1.id)
    @proj_1.roles << build(:role_owner, user_id: @user.id, organization_id: @org_1.id)
    @proj_1.roles << build(:role_admin, user_id: @user_2.id, organization_id: @org_1.id)

    @proj_2 = create(:project, user_id: @user.id, organization_id: @org_1.id)
    @proj_2.roles << build(:role_owner, user_id: @user.id, organization_id: @org_1.id)

    # org_2

    org_2 = create(:organization, title: 'Organization_2')
    org_2.roles << build(:role_owner, user_id: @user.id)
    proj_3 = create(:project, user_id: @user_2.id, organization_id: org_2.id)

    # org_2
    org_3 = create(:organization, title: 'Organization_3')
    org_3.roles << build(:role_owner, user_id: @user_2.id)


    proj_3.roles << build(:role_developer, user_id: @user.id, organization_id: org_3.id)
    proj_4 = create(:project, user_id: @user_2.id, organization_id: org_3.id)
    proj_4.roles << build(:role_owner, user_id: @user.id, organization_id: org_3.id)

    # Role.create(user_id: @user.id, role: 4,
    #             organization_id: org_3, project_id: proj_4.id)

    @owned_organizations = @user.organizations
                .select { |org| org.owner == @user }
  end

  def create_project_with_only_owner
    ColumnSet.generate_default
    org_1 = create(:organization, title: 'Organization_1')
    org_1.roles << build(:role_owner, user_id: @user.id)
    @proj_1 = create(:project, user_id: @user.id, organization_id: org_1.id)
    @proj_1.roles << build(:role_owner, user_id: @user.id, organization_id: org_1.id)
  end

  def status_dependence_create
    @subject_2 = FactoryGirl.create(:project)
    3.times do
      FactoryGirl.create(:status)
    end
    @status_objects = Status.all

    @status_objects.each do |obj|
      FactoryGirl.create(:project_status, project_id: @subject_2.id,
                           status_id: obj.id) if obj != @status_objects[2]
      FactoryGirl.create(:project_status, project_id: subject.id,
                           status_id: obj.id) if obj == @status_objects[2]
    end
  end

  def create_test_data_for_member
    create_test_data
    Role.create(user_id: @member_with_projects.id, role: 2,
          organization_id: Organization.first.id)
    Role.create(user_id: @member_with_projects.id, role: 5,
          organization_id: Organization.first.id,
          project_id: @proj_1.id)
    Role.create(user_id: @member_with_projects.id, role: 4,
          organization_id: Organization.first.id,
          project_id: @proj_2.id)
  end
end
