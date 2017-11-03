require 'rails_helper'
require_relative 'feature_helper'

feature 'Organization members page' do

  background do
    @user = FactoryGirl.create(:user)
    login_as @user, scope: :user
  end

  xscenario 'user can set his photo' do
    visit edit_user_path

    expect(page.has_button?('Save')).to be_truthy

    attach_file 'Avatar', "#{Rails.root}/config.ru"
    click_on(I18n.t('save'))

    # it { should have_attached_file(:avatar) }
    # expect(@user.avatar_file_name).to eq 'config.ru'
  end
end
