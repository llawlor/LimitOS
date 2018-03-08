require 'rails_helper'

RSpec.describe DevicesController, type: :controller do

  let(:user) { FactoryBot.create(:user) }
  let(:device) { FactoryBot.create(:device, user: user) }
  let(:device_without_user) { FactoryBot.create(:device, user: nil) }

  describe '#index' do
    it 'sets @devices correctly for a user' do
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
