require 'rails_helper'

RSpec.describe ColumnVisibilitiesController, type: :controller do
  before :each do
    ColumnSet.generate_default
    @owner = create(:user)
    @user = create(:user)
    organization = create(:organization)
    create(:role_owner, user: @owner, organization: organization)
    create(:role_user, user: @user, organization: organization)
    @project = create(:project, organization: organization)
    create(:role_owner, user: @owner, organization: organization, project: @project)
    create(:role_tester, user: @user, organization: organization, project: @project)
    @test_plan = create(:test_plan, project: @project)
    @test_run = create(:test_run, assigner: @owner, test_plan: @test_plan, project: @project)
    sign_in @owner
  end

  describe '#edit' do
    it 'returns 204 code for unexisting id param' do
      get :edit, params: { id: 0 }
      expect(response).to have_http_status(:no_content)
    end

    it 'returns 200 status for existing id' do
      get :edit, params: { id: @test_plan.column_visibility(@owner).id }
      expect(response).to have_http_status(:ok)
    end

    context 'pass id that belongs to another user' do
      it 'returns forbidden' do
        get :edit, params: { id: @test_plan.column_visibility(@user).id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe '#update' do
    context 'pass valid values' do
      it 'it updates test_plan visibility' do
        pre_create_count = ColumnSet.count
        cols = @test_plan.column_visibility(@owner).column_set.names
        cols.pop
        put :update, params: { id: @test_plan.column_visibility(@owner).id,
                               names: cols,
                               format: :js }
        expect(response).to have_http_status(:ok)
        expect(ColumnSet.count).to be > pre_create_count
      end

      it 'it updates test_run visibility' do
        pre_create_count = ColumnSet.count
        cols = @test_run.column_visibility(@owner).column_set.names
        cols.pop
        put :update, params: { id: @test_run.column_visibility(@owner).id,
                               names: cols,
                               format: :js }
        expect(response).to have_http_status(:ok)
        expect(ColumnSet.count).to be > pre_create_count
      end
    end

      context 'pass 0 value as id' do
        it 'returns 204 code' do
          put :update, params: { id: 0 }
          expect(response).to have_http_status(204)
        end
      end

      context 'pass id that belongs to another user' do
        it 'returns forbidden' do
          put :update, params: { id: @test_plan.column_visibility(@user).id }
          expect(response).to have_http_status(:forbidden)
        end
      end

    end
  end
