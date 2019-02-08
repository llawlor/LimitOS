require 'rails_helper'

RSpec.describe ControlController, type: :controller do

  let(:user) { FactoryBot.create(:user) }
  let(:device) { FactoryBot.create(:device, user: user, slug: 'my car') }
  let(:device_without_user) { FactoryBot.create(:device, user: nil, slug: 'my car 2') }

  describe '#edit' do
    it "shows the edit page when the user is signed in" do
      sign_in(user)
      get :edit, params: { slug: device.id }
      expect(response).to be_successful
    end

    it "shows the edit page when the user is signed in and uses a slug" do
      sign_in(user)
      get :edit, params: { slug: device.slug }
      expect(response).to be_successful
    end

    it "does not show the edit page when the user is signed out" do
      get :edit, params: { slug: device.id }
      expect(response.body).to eq('No device')
    end

    it "shows the edit page using @devices" do
      cookies.encrypted[:device_ids] = [device_without_user.id]
      get :edit, params: { slug: device_without_user.id }
      expect(response).to be_successful
    end

    it "shows the edit page using @devices and slug as the parameter" do
      cookies.encrypted[:device_ids] = [device_without_user.id]
      get :edit, params: { slug: device_without_user.slug }
      expect(response).to be_successful
    end

    it "does not show the edit page when the user is not signed in and the device is public" do
      device.update_attributes(public: true)
      get :edit, params: { slug: device.id }
      expect(response.body).to eq('No device')
    end

    it "does not show the edit page when the user is incorrect" do
      user_2 = FactoryBot.create(:user)
      sign_in(user_2)
      get :edit, params: { slug: device.id }
      expect(response.body).to eq('No device')
    end

    it 'does not show the edit page if @devices is blank' do
      cookies.encrypted[:device_ids] = []
      get :edit, params: { slug: device.id }
      expect(response.body).to eq('No device')
    end
  end

  describe '#update' do
    it "updates a user's device when the user is signed in" do
      sign_in(user)
      patch :update, params: { slug: device.id, device: { slug: 'new slug' } }
      expect(response).to redirect_to("/control/new-slug")
      device.reload
      expect(device.slug).to eq('new-slug')
    end

    it "updates to the 'drive' template" do
      sign_in(user)
      patch :update, params: { slug: device.id, device: { control_template: 'drive' } }
      expect(response).to redirect_to("/drive/#{device.slug}")
      device.reload
      expect(device.control_template).to eq('drive')
    end

    it "updates a device using @devices" do
      cookies.encrypted[:device_ids] = [device_without_user.id]
      patch :update, params: { slug: device_without_user.id, device: { slug: 'new slug' } }
      expect(response).to redirect_to("/control/new-slug")
      device_without_user.reload
      expect(device_without_user.slug).to eq('new-slug')
    end

    it "updates a device using @devices and slug as the parameter" do
      cookies.encrypted[:device_ids] = [device_without_user.id]
      patch :update, params: { slug: device_without_user.slug, device: { slug: 'new slug' } }
      expect(response).to redirect_to("/control/new-slug")
      device_without_user.reload
      expect(device_without_user.slug).to eq('new-slug')
    end

    it "does not update a user's device when the user is not signed in" do
      patch :update, params: { slug: device.id, device: { slug: 'new slug' } }
      expect(response.body).to eq('No device')
    end

    it "does not update a user's device when the user is not signed in and the device is public" do
      device.update_attributes(public: true)
      patch :update, params: { slug: device.id, device: { slug: 'new slug' } }
      expect(response.body).to eq('No device')
    end

    it "does not update a user's device when the user is incorrect" do
      user_2 = FactoryBot.create(:user)
      sign_in(user_2)
      patch :update, params: { slug: device.id, device: { slug: 'new slug' } }
      expect(response.body).to eq('No device')
    end

    it 'does not update a device if @devices is blank' do
      cookies.encrypted[:device_ids] = []
      patch :update, params: { slug: device_without_user.id, device: { slug: 'new slug' } }
      expect(response.body).to eq('No device')
    end
  end

  describe '#show' do
    render_views

    it 'should not show a private device when no user signed in' do
      device.update(public: false)
      get :show, params: { slug: device.id }
      expect(response.body).to eq('No device')
    end

    it 'should show a public device when no user signed in' do
      device.update(public: true)
      get :show, params: { slug: device.id }
      expect(response.body).to_not eq('No device')
    end

    it 'sets @device correctly for a user' do
      sign_in(user)
      get :show, params: { slug: device.id }
      expect(assigns(:device)).to eq(device)
    end

    it 'gets @device correctly for a user using the slug' do
      sign_in(user)
      get :show, params: { slug: device.slug }
      expect(assigns(:device)).to eq(device)
    end

    it 'does not set @device if incorrect id' do
      sign_in(user)
      get :show, params: { slug: 0 }
      expect(response.body).to eq('No device')
      expect(assigns(:device)).to eq(nil)
    end

    it 'sets @device correctly for a visitor' do
      cookies.encrypted[:device_ids] = [device_without_user.id]
      get :show, params: { slug: device_without_user.id }
      expect(assigns(:device)).to eq(device_without_user)
    end

    it 'does not set @device for a visitor if incorrect id' do
      cookies.encrypted[:device_ids] = [device_without_user.id]
      get :show, params: { slug: 0 }
      expect(response.body).to eq('No device')
      expect(assigns(:device)).to eq(nil)
    end

    it 'does not set @device for a visitor if device has a user' do
      cookies.encrypted[:device_ids] = [device.id]
      get :show, params: { slug: device.id }
      expect(response.body).to eq('No device')
      expect(assigns(:device)).to eq(nil)
    end

    it 'sets @owner to true' do
      sign_in(user)
      get :show, params: { slug: device.id }
      expect(assigns(:owner)).to eq(true)
    end

    it 'sets @owner to false' do
      get :show, params: { slug: device.id }
      expect(assigns(:owner)).to eq(false)
    end

    it 'sets @owner to false even if device is public' do
      device.update(public: true)
      get :show, params: { slug: device.id }
      expect(assigns(:owner)).to eq(false)
    end

    it 'includes the auth token' do
      sign_in(user)
      get :show, params: { slug: device.id }
      expect(response.body).to include(device.auth_token)
    end

    it 'should not include the auth token if the device is public' do
      sign_in(user)
      device.update(public: true)
      get :show, params: { slug: device.id }
      expect(response.body).to_not include(device.auth_token)
    end
  end

end
