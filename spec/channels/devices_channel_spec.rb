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

  describe '#request_device_information' do
    it 'broadcasts successfully' do
      subscription = subscribe(id: device.id, auth_token: device.auth_token)
      expect {
        subscription.request_device_information
      }.to have_broadcasted_to(device.id).with(hash_including({ slave_devices: [] }))
    end

    it 'does not broadcast with no device id' do
      subscription = subscribe(id: device.id, auth_token: device.auth_token)
      # change params for the 'receive' method
      subscription.instance_variable_set(:@params, { })
      broadcasted_message = nil
      expect {
        broadcasted_message = subscription.request_device_information
      }.to_not have_broadcasted_to(device.id)
      expect(broadcasted_message).to eq(false)
    end

    it 'does not broadcast with incorrect device id' do
      subscription = subscribe(id: device.id, auth_token: device.auth_token)
      # change params for the 'receive' method
      subscription.instance_variable_set(:@params, { id: 0 })
      broadcasted_message = nil
      expect {
        broadcasted_message = subscription.request_device_information
      }.to_not have_broadcasted_to(device.id)
      expect(broadcasted_message).to eq(false)
    end

    it 'does not broadcast with incorrect auth token' do
      subscription = subscribe(id: device.id, auth_token: device.auth_token)
      # change params for the 'receive' method
      subscription.instance_variable_set(:@params, { id: device.id, auth_token: 'INVALID_AUTH_TOKEN' })
      broadcasted_message = nil
      expect {
        broadcasted_message = subscription.request_device_information
      }.to_not have_broadcasted_to(device.id)
      expect(broadcasted_message).to eq(false)
    end
  end

  describe '#receive' do
    it 'performs a status update' do
      expect(device.last_active_at).to eq(nil)
      subscription = subscribe(id: device.id, auth_token: device.auth_token)
      subscription.receive({ "status_update" => true })
      expect(device.reload.last_active_at).to_not eq(nil)
    end

    it 'receives and broadcasts successfully' do
      subscription = subscribe(id: device.id, auth_token: device.auth_token)
      expect {
        subscription.receive({ pin: '5', servo: '12' })
      }.to have_broadcasted_to(device.id).with(hash_including({ pin: '5', servo: '12' }))
    end

    it 'broadcasts to a target device' do
      target_device = FactoryBot.create(:device)
      device.update_attributes(broadcast_to_device_id: target_device.id)
      subscription = subscribe(id: device.id, auth_token: device.auth_token)
      expect {
        subscription.receive({ pin: '5', servo: '12' })
      }.to have_broadcasted_to(target_device.id).with(hash_including({ pin: '5', servo: '12' }))
    end

    it 'does not broadcast with no device id' do
      subscription = subscribe(id: device.id, auth_token: device.auth_token)
      # change params for the 'receive' method
      subscription.instance_variable_set(:@params, { })
      broadcasted_message = nil
      expect {
        broadcasted_message = subscription.receive({ pin: '5', servo: '12' })
      }.to_not have_broadcasted_to(device.id)
      expect(broadcasted_message).to eq(false)
    end

    it 'does not broadcast with incorrect device id' do
      subscription = subscribe(id: device.id, auth_token: device.auth_token)
      # change params for the 'receive' method
      subscription.instance_variable_set(:@params, { id: 0 })
      broadcasted_message = nil
      expect {
        broadcasted_message = subscription.receive({ pin: '5', servo: '12' })
      }.to_not have_broadcasted_to(device.id)
      expect(broadcasted_message).to eq(false)
    end

    it 'does not broadcast with incorrect auth token' do
      subscription = subscribe(id: device.id, auth_token: device.auth_token)
      # change params for the 'receive' method
      subscription.instance_variable_set(:@params, { id: device.id, auth_token: 'INVALID_AUTH_TOKEN' })
      broadcasted_message = nil
      expect {
        broadcasted_message = subscription.receive({ pin: '5', servo: '12' })
      }.to_not have_broadcasted_to(device.id)
      expect(broadcasted_message).to eq(false)
    end
  end

end
