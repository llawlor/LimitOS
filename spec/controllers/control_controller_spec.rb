require 'rails_helper'

RSpec.describe ControlController, type: :controller do

  let(:user) { FactoryBot.create(:user) }
  let(:device) { FactoryBot.create(:device, user: user, slug: 'my car') }
  let(:device_without_user) { FactoryBot.create(:device, user: nil, slug: 'my car 2') }

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
  end

end
