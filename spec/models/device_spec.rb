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
#

require 'rails_helper'

RSpec.describe Device, type: :model do

  # lazy loaded variables
  let(:user) { FactoryGirl.create(:user) }
  let(:device) { FactoryGirl.build(:device, user: user) }

  describe 'validations' do
    it 'should be valid' do
      device.should be_valid
      device.name.should_not be_blank
    end

    it 'should be invalid if name is nil' do
      device.name = nil
      device.should_not be_valid
    end

    it 'should be invalid if name is a blank string' do
      device.name = ''
      device.should_not be_valid
    end
  end
end
