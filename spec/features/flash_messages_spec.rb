require 'rails_helper'
require_relative 'feature_helper'

feature 'Flash messages' do
  feature 'Sign In page' do
    # scenario 'error messege shown for invalid credentials', js: true do
    #   visit new_user_session_path
    #   within('.sign-form') do
    #     click_on I18n.t('sign_in')
    #   end
    #   expect(page).to have_content 'Invalid Email or password.'
    # end
  end
end
