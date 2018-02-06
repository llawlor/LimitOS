# == Schema Information
#
# Table name: devices
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  name        :string(255)
#  device_id   :integer
#  device_type :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  auth_token  :string(24)
#  i2c_address :string(10)
#

require 'rails_helper'

RSpec.describe Device, type: :model do

  # lazy loaded variables
  let(:user) { FactoryGirl.create(:user) }
  let(:device) { FactoryGirl.build(:device, user: user) }

  describe 'validations' do
    it 'should be valid' do
      expect(device).to be_valid
      expect(device.name).to_not be_blank
      expect(device.user_id).to eq(user.id)
    end

    it 'should be valid with no data' do
      device.update_attributes(name: nil, user_id: nil, device_type: nil)
      expect(device).to be_valid
    end

    it 'should set the auth_token automatically' do
      expect(device.auth_token).to eq(nil)
      device.save
      expect(device.auth_token.length).to eq(24)
    end
  end

  describe '#parent_device' do
    it 'gets the parent device' do
      device2 = FactoryGirl.create(:device, device: device)
      expect(device2.parent_device).to eq(device)
    end
  end
end
