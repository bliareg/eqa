require 'rails_helper'
require_relative 'feature_helper'

shared_examples 'main_header_present' do |path| # |user|
  login_as FactoryGirl.create(:user), scope: :user

  scenario 'main header link "My Organizations" present' do
    visit eval(path)
    expect(page).to have_content 'My Organizations'
  end

  scenario 'main header links are present' do
    check_logged_header
  end
end
