require 'rails_helper'

RSpec.describe Role, type: :model do

  it 'is invalid without user_id' do
    role = Role.new
    role.valid?

    expect(role.errors.messages.include?(:user_id)).to be_truthy
  end

  it 'is invalid without organization_id' do
    role = Role.new
    role.valid?

    expect(role.errors.messages.include?(:organization_id)).to be_truthy
  end

  it 'is invalid without role' do
    role = Role.new
    role.valid?

    expect(role.errors.messages.include?(:role)).to be_truthy
  end

  it 'user can have only one role per organization' do
    organization = create(:organization)
    user = create(:user)
    indexes = Role.role.values.each_with_index.map { |role, index| index }
    indexes.each do |role_id|
      first_role = Role.create(user_id: user.id, organization_id: organization.id, role: role_id)

      indexes.each do |another_role_id|
        second_role = Role.new(user_id: user.id, organization_id: organization.id, role: another_role_id)
        expect(second_role.valid?).to be_falsey
        expect(second_role.errors.messages.include?(:project_id)).to be_truthy
      end
      first_role.destroy
    end
  end

  it 'user can have only one role per project' do
    organization = create(:organization)
    project = build(:project, organization: organization)
    project.organization_id = organization.id
    project.save

    user = create(:user)
    indexes = Role.role.values.each_with_index.map { |role, index| index }
    indexes.each do |role_id|
      first_role = Role.create(user_id: user.id, role: role_id,
                               organization_id: organization.id, project_id: project.id)

      indexes.each do |another_role_id|
        second_role = Role.create(user_id: user.id, role: role_id,
                                  organization_id: organization.id, project_id: project.id)
        expect(second_role.valid?).to be_falsey
        expect(second_role.errors.messages.include?(:project_id)).to be_truthy
      end
      first_role.destroy
    end
  end

  it '#user_owner? returns true if user has at least 1 "owner" role' do
    user = create(:user)
    5.times { create(:organization) }
    owned_organization = create(:organization, owner_id: user.id)

    role = Role.find_by(project_id: nil, user_id: user.id)
    expect(role.user_owner?).to be_truthy
  end

  it '#user_owner? returns false if user hasn"t even 1 "owner" role' do
    user = create(:user)
    5.times { create(:organization) }
    create(:role_user, organization_id: Organization.last.id, user_id: user.id)

    role = Role.find_by(user_id: user.id)
    expect(role.user_owner?).to be_falsey
  end
end
