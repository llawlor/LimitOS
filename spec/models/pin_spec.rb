# == Schema Information
#
# Table name: pins
#
#  id                :integer          not null, primary key
#  device_id         :integer
#  name              :string(255)
#  pin_type          :string(255)
#  pin_number        :integer
#  min               :integer
#  max               :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  transform         :string(255)
#  output_pin_number :integer
#

require 'rails_helper'

RSpec.describe Pin, type: :model do
  before :each do
    allow_any_instance_of(Device).to receive(:broadcast_slave_device_information).and_return(nil)
  end

  # lazy loaded variables
  let(:device) { FactoryBot.create(:device) }
  let(:pin) { FactoryBot.build(:pin, device_id: device.id) }

  describe 'validations' do
    it 'is valid' do
      expect(pin).to be_valid
    end

    it 'checks for a device_id' do
      pin.device_id = nil
      expect(pin).to be_invalid
    end
  end

  describe '#send_slave_device_information' do
    it 'sends on create' do
      device.save
      expect_any_instance_of(Device).to receive(:broadcast_slave_device_information).once
      pin.save
    end

    it 'sends on update' do
      device.save
      pin.save
      expect_any_instance_of(Device).to receive(:broadcast_slave_device_information).once
      pin.update_attributes(pin_number: 5)
    end

    it 'sends on destroy' do
      device.save
      pin.save
      expect_any_instance_of(Device).to receive(:broadcast_slave_device_information).once
      pin.destroy
    end
  end

end
