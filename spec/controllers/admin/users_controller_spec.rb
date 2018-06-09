require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do

  let(:admin_user) { FactoryBot.create(:user, admin: true) }
  let(:user) { FactoryBot.create(:user) }

  describe 'admin access' do
    it 'allows admins to access the interface' do
      sign_in(admin_user)
      get :index
      expect(response.status).to eq(200)
    end

    it 'does not allow non-admins to access the interface' do
      sign_in(user)
      get :index
      expect(response).to redirect_to(root_path)
    end

    it 'does not allow logged out users to access the interface' do
      get :index
      expect(response).to redirect_to(root_path)
    end
  end

end
