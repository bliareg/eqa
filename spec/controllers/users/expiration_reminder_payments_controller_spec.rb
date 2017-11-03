require 'rails_helper'

RSpec.describe Users::ExpirationReminderPaymentsController, type: :controller do

  describe "GET #expired" do
    it "returns http success" do
      get :expired
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #expiring" do
    it "returns http success" do
      get :expiring
      expect(response).to have_http_status(:success)
    end
  end

end
