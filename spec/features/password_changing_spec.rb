require 'rails_helper'
require_relative 'feature_helper'

feature 'Password changing' do
  background do
    @password = 'foobarrr'
    @new_password = 'qwer34rtyu'
    @user = FactoryGirl.create(:user, password: @password,
                                      password_confirmation: @password)
    login_as @user, scope: :user
    visit edit_password_path
  end

  scenario 'require current password' do
    # Capybara.default_max_wait_time= 10
    # save_screenshot
    # byebug
    expect(page).to have_content(I18n.t('users.current_password'))

    within('form#edit_user_password') do
      fill_in 'current_password', with: @password
      fill_in I18n.t('users.new_password'), with: @new_password
      fill_in I18n.t('activerecord.attributes.user.password_confirmation'), with: @new_password
      click_on I18n.t('save')
    end

    expect(page).to have_content(I18n.t('users.personal_information'))
  end

  scenario 'impossible with wrong current password' do
    visit edit_password_path
    expect(page).to have_content(I18n.t('users.current_password'))

    within('form.edit_user') do
      fill_in 'current_password', with: 'wrongpassword'
      fill_in I18n.t('users.new_password'), with: @new_password
      fill_in I18n.t('activerecord.attributes.user.password_confirmation'), with: @new_password
      click_on I18n.t('save')
    end

    expect(page).to have_content(I18n.t('users.incorrect_password'))
  end
end
