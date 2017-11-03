require 'rails_helper'

RSpec.describe StatusesController, type: :controller do

  describe 'POST #create' do

    context 'with valid attributes' do

      it "saves the new status in the database" do
        project = create(:setup_project)
        user = create(:user, organization: project.organization, role: :admin)

        sign_in user

        expect { process(:create,
                         method: :post,
                         params: { project_id: project.id }) }.to change(Status, :count).by(1)
      end
    end
  end
end
