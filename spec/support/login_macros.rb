module LoginMacros

  def sign_in_from_view(user)
    visit new_user_session_path
    within '#new_user' do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button I18n.t 'sign_in'
    end
  end

  def sign_in_with_user
    sign_in_from_view(FactoryGirl.create(:user))
  end

  def create_logged_in_user
    user = create(:user)
    login(user)
    user
  end

  def login(user)
    login_as user, scope: :user
  end
end
