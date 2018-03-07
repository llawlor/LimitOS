require 'rails_helper'

RSpec.describe DevicesController, type: :controller do

  let(:user) { FactoryBot.create(:user) }
  let(:device) { FactoryBot.create(:device, user: user) }

  describe '#nodejs_script' do
    render_views

    it 'shows the nodejs script to a user' do
      sign_in(user)
      get :nodejs_script, params: { id: device.id }
      expect(response).to be_successful
    end

    it 'does not show the nodejs script to a user if incorrect id' do
      sign_in(user)
      expect {
        get :nodejs_script, params: { id: 0 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#send_message' do
    before :each do
      allow(DevicesChannel).to receive(:broadcast_to) { nil }
    end

    it 'sends a message' do
      expect(DevicesChannel).to receive(:broadcast_to)
      post :send_message, params: { id: device.id, auth_token: device.auth_token, message: { pin: 1 } }
    end

    it 'does not send a message if the auth_token is incorrect' do
      expect(DevicesChannel).to_not receive(:broadcast_to)
      post :send_message, params: { id: device.id, auth_token: 'INVALID_TOKEN', message: { pin: 1 } }
    end
  end
end
