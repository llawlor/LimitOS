require 'rails_helper'

RSpec.describe PinsController, type: :controller do

  let(:user) { FactoryBot.create(:user) }
  let(:device) { FactoryBot.create(:device, user: user) }
  let(:pin) {FactoryBot.create(:pin, device: device) }

end
