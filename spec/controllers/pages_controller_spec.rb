require 'rails_helper'

RSpec.describe PagesController, type: :controller do

  it "user signs in" do
    sign_in user create(:user)
    get :index

    expect(response.success?).to be_truthy
  end
end
