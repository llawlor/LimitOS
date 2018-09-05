require 'rails_helper'

RSpec.describe DevicesController, type: :controller do

  let(:user) { FactoryBot.create(:user) }
  let(:device) { FactoryBot.create(:device, user: user) }
  let(:device_without_user) { FactoryBot.create(:device, user: nil) }

  describe '#submit_registration' do
    before :each do
      @registration = FactoryBot.create(:registration, device: device_without_user, expires_at: 1.minute.from_now)
    end

    it 'registers a device for the current user' do
      sign_in(user)
      expect {
        post :submit_registration, params: { registration: { auth_token: @registration.auth_token } }
      }.to change{ Registration.count }.by(-1)
      expect(device_without_user.reload.user_id).to eq(user.id)
      expect(device_without_user.device_type).to eq('raspberry_pi')
    end

    it 'registers a device for an anonymous user' do
      expect {
        post :submit_registration, params: { registration: { auth_token: @registration.auth_token } }
      }.to change{ Registration.count }.by(-1)
      expect(device_without_user.reload.user_id).to eq(nil)
      expect(cookies.encrypted[:device_ids]).to eq([device_without_user.id])
    end

    it 'does not register an expired registration' do
      sign_in(user)
      @registration.update_attributes(expires_at: 1.minute.ago)
      expect {
        post :submit_registration, params: { registration: { auth_token: @registration.auth_token } }
      }.to change{ Registration.count }.by(0)
      expect(device_without_user.reload.user_id).to eq(nil)
    end
  end

  describe '#create' do
    it 'creates a new device' do
      post :create, params: { device: { name: 'new name' } }
      new_device = Device.last
      expect(response).to redirect_to(device_path(new_device))
      expect(new_device.name).to eq('new name')
    end

    it "creates a new device but doesn't allow broadcast_to_device_id to be set" do
      post :create, params: { device: { name: 'new name', broadcast_to_device_id: device.id } }
      new_device = Device.last
      expect(response).to redirect_to(device_path(new_device))
      expect(new_device.name).to eq('new name')
      expect(new_device.broadcast_to_device_id).to eq(nil)
    end
  end

  describe '#update' do
    it "updates a user's device when the user is signed in" do
      sign_in(user)
      patch :update, params: { id: device.id, device: { name: 'new name' } }
      expect(response).to redirect_to(device_path(device))
      device.reload
      expect(device.name).to eq('new name')
    end

    it "updates a device using @devices" do
      cookies.encrypted[:device_ids] = [device_without_user.id]
      patch :update, params: { id: device_without_user.id, device: { name: 'new name' } }
      expect(response).to redirect_to(device_path(device_without_user))
      device_without_user.reload
      expect(device_without_user.name).to eq('new name')
    end

    it "does not update a user's device when the user is not signed in" do
      patch :update, params: { id: device.id, device: { name: 'new name' } }
      expect(response.body).to eq('No device')
    end

    it "does not update a user's device when the user is incorrect" do
      user_2 = FactoryBot.create(:user)
      sign_in(user_2)
      patch :update, params: { id: device.id, device: { name: 'new name' } }
      expect(response.body).to eq('No device')
    end

    it 'does not update a device if @devices is blank' do
      cookies.encrypted[:device_ids] = []
      patch :update, params: { id: device_without_user.id, device: { name: 'new name' } }
      expect(response.body).to eq('No device')
    end

    it 'allows a broadcast_to_device to be set if the user is the same' do
      sign_in(user)
      device_2 = FactoryBot.create(:device, user: user)
      patch :update, params: { id: device.id,  device: { broadcast_to_device_id: device_2.id } }
      expect(response).to redirect_to(device_path(device))
      device.reload
      expect(device.broadcast_to_device).to eq(device_2)
    end

    it 'allows a broadcast_to_device to be set if both are in @devices' do
      device_2 = FactoryBot.create(:device, user: nil)
      cookies.encrypted[:device_ids] = [device_without_user.id, device_2.id]
      patch :update, params: { id: device_without_user.id,  device: { broadcast_to_device_id: device_2.id } }
      expect(response).to redirect_to(device_path(device_without_user))
      device_without_user.reload
      expect(device_without_user.broadcast_to_device).to eq(device_2)
    end

    it 'does not allow a broadcast_to_device to be set if the user is different' do
      sign_in(user)
      user_2 = FactoryBot.create(:user)
      device_2 = FactoryBot.create(:device, user: user_2)
      patch :update, params: { id: device.id,  device: { broadcast_to_device_id: device_2.id } }
      expect(response.body).to eq('Unauthorized')
      device.reload
      expect(device.broadcast_to_device).to eq(nil)
    end

    it 'does not allow a broadcast_to_device to be set if both are not in @devices' do
      device_2 = FactoryBot.create(:device, user: nil)
      cookies.encrypted[:device_ids] = [device_without_user.id]
      patch :update, params: { id: device_without_user.id,  device: { broadcast_to_device_id: device_2.id } }
      expect(response.body).to eq('Unauthorized')
      device.reload
      expect(device.broadcast_to_device).to eq(nil)
    end
  end

  describe '#install' do
    render_views

    it 'shows the install script for a new device' do
      get :install
      expect(response).to be_successful
      expect(assigns(:device)).to eq(nil)
    end

    it 'shows the install script for an existing device' do
      get :install, params: { id: device.id, auth_token: device.auth_token }
      expect(response).to be_successful
      expect(assigns(:device)).to eq(device)
    end

    it 'shows the install script but not for a specific device if the auth_token is invalid' do
      get :install, params: { id: device.id, auth_token: 'INVALID_AUTH_TOKEN' }
      expect(response).to be_successful
      expect(assigns(:device)).to eq(nil)
    end
  end

  describe '#index' do
    render_views

    it 'sets @devices correctly for a user' do
      # save the device since it's lazy-loaded and hasn't been used yet
      device.save
      sign_in(user)
      get :index
      expect(assigns(:devices)).to eq([device])
    end

    it 'sets @devices correctly for a visitor' do
      cookies.encrypted[:device_ids] = [device_without_user.id]
      get :index
      expect(assigns(:devices)).to eq([device_without_user])
    end

    it 'does not set @devices for a visitor if device has a user_id' do
      cookies.encrypted[:device_ids] = [device.id]
      get :index
      expect(assigns(:devices)).to eq([])
    end
  end

  describe '#show' do
    render_views

    it 'sets @device correctly for a user' do
      sign_in(user)
      get :show, params: { id: device.id }
      expect(assigns(:device)).to eq(device)
    end

    it 'does not set @device if incorrect id' do
      sign_in(user)
      get :show, params: { id: 0 }
      expect(response.body).to eq('No device')
      expect(assigns(:device)).to eq(nil)
    end

    it 'sets @device correctly for a visitor' do
      cookies.encrypted[:device_ids] = [device_without_user.id]
      get :show, params: { id: device_without_user.id }
      expect(assigns(:device)).to eq(device_without_user)
    end

    it 'does not set @device for a visitor if incorrect id' do
      cookies.encrypted[:device_ids] = [device_without_user.id]
      get :show, params: { id: 0 }
      expect(response.body).to eq('No device')
      expect(assigns(:device)).to eq(nil)
    end

    it 'does not set @device for a visitor if device has a user' do
      cookies.encrypted[:device_ids] = [device.id]
      get :show, params: { id: device.id }
      expect(response.body).to eq('No device')
      expect(assigns(:device)).to eq(nil)
    end
  end

  describe '#nodejs_script' do
    render_views

    it 'shows the nodejs script to a user' do
      sign_in(user)
      get :nodejs_script, params: { id: device.id }
      expect(response).to be_successful
      expect(assigns(:device)).to eq(device)
    end

    it 'does not show the nodejs script to a user if incorrect id' do
      sign_in(user)
      get :nodejs_script, params: { id: 0 }
      expect(response).to be_successful
      expect(response.body).to eq('No device')
      expect(assigns(:device)).to eq(nil)
    end

    it 'shows the nodejs script to a visitor' do
      cookies.encrypted[:device_ids] = [device_without_user.id]
      get :nodejs_script, params: { id: device_without_user.id }
      expect(response).to be_successful
      expect(assigns(:device)).to eq(device_without_user)
    end

    it 'does not show the nodejs script for a visitor if device has a user' do
      cookies.encrypted[:device_ids] = [device.id]
      get :nodejs_script, params: { id: device.id }
      expect(response.body).to eq('No device')
      expect(assigns(:device)).to eq(nil)
    end
  end

  describe '#send_message' do
    it 'sends a message' do
      expect {
        post :send_message, params: { id: device.id, auth_token: device.auth_token, message: { pin: 5, servo: 12 } }
      }.to have_broadcasted_to(device.id).from_channel(DevicesChannel).with(hash_including({ pin: '5', servo: '12' }))
      expect(response).to be_successful
      expect(response.body).to be_blank
    end

    it 'sends a message to a target device' do
      target_device = FactoryBot.create(:device)
      device.update_attributes(broadcast_to_device_id: target_device.id)
      expect {
        post :send_message, params: { id: device.id, auth_token: device.auth_token, message: { pin: 5, servo: 12 } }
      }.to have_broadcasted_to(target_device.id).from_channel(DevicesChannel).with(hash_including({ pin: '5', servo: '12' }))
      expect(response).to be_successful
      expect(response.body).to be_blank
    end

    it 'does not send a message with incorrect device id' do
      expect {
        post :send_message, params: { id: 0, auth_token: 'INVALID_TOKEN', message: { pin: 5, servo: 12 } }
      }.to_not have_broadcasted_to(device.id).from_channel(DevicesChannel)
      expect(response).to be_successful
      expect(response.body).to eq('Unauthorized')
    end

    it 'does not send a message if the auth_token is incorrect' do
      expect {
        post :send_message, params: { id: device.id, auth_token: 'INVALID_TOKEN', message: { pin: 5, servo: 12 } }
      }.to_not have_broadcasted_to(device.id).from_channel(DevicesChannel)
      expect(response).to be_successful
      expect(response.body).to eq('Unauthorized')
    end
  end
end
