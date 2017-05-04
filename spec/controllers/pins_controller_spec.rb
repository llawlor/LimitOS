require 'rails_helper'

RSpec.describe PinsController, type: :controller do

  let(:user) { FactoryGirl.create(:user) }
  let(:device) { FactoryGirl.create(:device, user: user) }
  let(:pin) {FactoryGirl.create(:pin, device: device) }

end
