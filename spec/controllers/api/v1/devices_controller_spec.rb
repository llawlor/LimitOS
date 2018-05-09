require 'rails_helper'

RSpec.describe Api::V1::DevicesController, type: :controller do

  let(:user) { FactoryBot.create(:user) }
  let(:device) { FactoryBot.create(:device, user: user) }
  let(:device_without_user) { FactoryBot.create(:device, user: nil) }

  describe '#nodejs_script' do
    render_views

    it 'returns the script' do
      post :nodejs_script, params: { id: device.id, auth_token: device.auth_token }
      expect(response.body).to match('function requestI2CData')
    end

    it 'returns an error if no device' do
      post :nodejs_script, params: { id: 0, auth_token: device.auth_token }
      expect(response.body).to match('Invalid device credentials.')
    end

    it 'returns an error if invalid auth token' do
      post :nodejs_script, params: { id: device.id, auth_token: 'INVALID' }
      expect(response.body).to match('Invalid device credentials.')
    end
  end

  describe '#create' do
    it 'creates a new device' do
      expect {
        post :create
      }.to change{ Device.count }.by(1)
      expect(JSON.parse(response.body)["auth_token"]).to eq(Device.last.auth_token)
    end
  end

end
