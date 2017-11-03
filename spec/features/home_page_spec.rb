require 'rails_helper'
require_relative 'feature_helper'

feature 'Home page and Sign In' do
  before :each do
    sign_in_from_view(FactoryGirl.create(:user))
  end

  scenario 'checking main page' do
    visit root_path
    expect(page).to have_content 'Project History'
  end

  scenario 'Sign In' do
    check_logged_header
  end
end
