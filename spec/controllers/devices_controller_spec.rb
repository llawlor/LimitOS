require 'rails_helper'

RSpec.describe DevicesController, type: :controller do

  let(:user) { FactoryBot.create(:user) }
  let(:device) { FactoryBot.create(:device, user: user) }

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
