require 'rails_helper'

RSpec.describe "Devices", type: :request do

  # lazy loaded variables
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) {  FactoryGirl.create(:user) }
  let(:device) { FactoryGirl.create(:device, user: user) }


  describe '#show' do
    it 'shows a device if it belongs to the user' do
      sign_in user
      get device_url(device)
      expect(response.status).to eq(200)
      expect(response.body).to include(device.name)
    end

    it "doesn't show a device if it doesn't belong to the user" do
      sign_in user2
      expect {
        get device_url(device)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end
