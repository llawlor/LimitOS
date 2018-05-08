require 'rails_helper'

RSpec.describe Api::V1::DevicesController, type: :controller do

  let(:user) { FactoryBot.create(:user) }
  let(:device) { FactoryBot.create(:device, user: user) }
  let(:device_without_user) { FactoryBot.create(:device, user: nil) }

  describe '#create' do
    it 'creates a new device' do
      expect {
        post :create
      }.to change{ Device.count }.by(1)
      expect(JSON.parse(response.body)["auth_token"]).to eq(Device.last.auth_token)
    end
  end

end
