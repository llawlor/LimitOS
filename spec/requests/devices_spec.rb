require 'rails_helper'

RSpec.describe "Devices", type: :request do

  # lazy loaded variables
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) {  FactoryGirl.create(:user) }
  let(:device) { FactoryGirl.create(:device, user: user) }
  let(:device_attributes) { FactoryGirl.attributes_for(:device) }

  describe 'device management' do
    it 'creates and views a device' do
      sign_in user

      # new device
      get new_device_url
      expect(response.status).to eq(200)

      # create new device
      expect {
        post devices_url, params: { device: device_attributes }
      }.to change{ user.devices.count }.by(1)
      new_device = Device.last
      expect(response).to redirect_to(device_url(new_device))

      # view devices
      get devices_url
      expect(response.status).to eq(200)
      expect(response.body).to include(new_device.name)

      # view the new device
      get device_url(new_device)
      expect(response.status).to eq(200)
      expect(response.body).to include(new_device.name)

      # edit the new device
      get edit_device_url(new_device)
      expect(response.status).to eq(200)
      expect(response.body).to include(new_device.name)

      # update the new device
      expect {
        patch device_url(new_device), params: { device: { name: 'my new device name' } }
      }.to change{ user.devices.count }.by(0)
      expect(response).to redirect_to(device_url(new_device))
      follow_redirect!
      expect(response.body).to include('my new device name')

      # delete the new device
      expect {
        delete device_url(new_device)
      }.to change{ user.devices.count }.by(-1)
      expect(response).to redirect_to(devices_url)
      follow_redirect!
      expect(response.body).to_not include('my new device name')
    end
  end

  describe 'not my device' do
    it "doesn't show a device if it doesn't belong to the user" do
      sign_in user2
      expect {
        get device_url(device)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end
