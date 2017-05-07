require 'rails_helper'

RSpec.describe DevicesController, type: :controller do

  # lazy loaded variables
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) {  FactoryGirl.create(:user) }
  let(:device) { FactoryGirl.create(:device, user: user) }


  describe '#show' do
    xit 'should only show devices belonging to the user' do
      sign_in user
      get 'show', id: device.id
      expect(assigns(:device)).to eq(device)
    end
  end
end
