require 'rails_helper'

RSpec.describe DevicesChannel, type: :channel do

  let(:device) { FactoryBot.create(:device) }

  describe '#subscribed' do
    it 'confirms with correct device id and auth_token' do
      subscribe(id: device.id, auth_token: device.auth_token)
      expect(subscription).to be_confirmed
      expect(streams).to include("devices:#{device.id}")
    end

    it 'rejects when no device id' do
      subscribe
      expect(subscription).to be_rejected
    end

    it 'rejects when incorrect device id' do
      subscribe(id: 0)
      expect(subscription).to be_rejected
    end

    it 'rejects when incorrect auth token' do
      subscribe(id: device.id, auth_token: 'INVALID_AUTH_TOKEN')
      expect(subscription).to be_rejected
    end
  end

  describe '#receive' do
    it 'receives and broadcasts successfully' do
      subscription = subscribe(id: device.id, auth_token: device.auth_token)
      broadcasted_message = subscription.receive({ pin: 5, servo: 12 })
      message_hash = JSON.parse(broadcasted_message.first).symbolize_keys
      expect(message_hash).to include({ pin: 5, servo: 12 })
    end
  end

end
