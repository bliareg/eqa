require 'rails_helper'
require_relative 'feature_helper'

feature 'Invitation' do

  background do
    @user = FactoryGirl.create(:user)
    create_test_data
    login_as @user, scope: :user
  end

  xscenario 'check text elements', js: true do
    visit organizations_path
    visit organization_profile_members_path(@org_1)
    click_on 'Add Members'
    save_page
    ['note', 'explanation', 'emails', 'use_separator', 'or_new_line',
     'to_separate', 'add_members', 'max_count', 'default_text'].each do |fraze|

      expect(page).to have_content I18n.t 'invite.'.concat(fraze)
    end
  end
end
