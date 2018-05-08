# == Schema Information
#
# Table name: devices
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  name                   :string(255)
#  device_id              :integer
#  device_type            :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  auth_token             :string(24)
#  i2c_address            :string(10)
#  broadcast_to_device_id :integer
#

require 'rails_helper'

RSpec.describe Device, type: :model do

  # lazy loaded variables
  let(:user) { FactoryBot.create(:user) }
  let(:device) { FactoryBot.build(:device, user: user) }

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

  describe '#transform_input_message' do
    before :each do
      device.save
    end

    it 'transforms the message if there is a transform' do
      pin = FactoryBot.create(:pin, pin_number: 3, device: device, pin_type: 'input', transform: 'x * 2')
      message = { "i2c_address" => "0x04", "pin" => 3, "servo" => 60 }
      device.transform_input_message(message)
      expect(message["servo"]).to eq(120)
      expect(message["pin"]).to eq(3)
    end

    it 'transforms pin number' do
      pin = FactoryBot.create(:pin, pin_number: 3, output_pin_number: 14, device: device, pin_type: 'input', transform: 'x * 2')
      message = { "i2c_address" => "0x04", "pin" => 3, "servo" => 60 }
      device.transform_input_message(message)
      expect(message["servo"]).to eq(120)
      expect(message["pin"]).to eq(14)
    end

    it "doesn't transform if no transform present" do
      pin = FactoryBot.create(:pin, pin_number: 3, device: device, pin_type: 'input')
      message = { "i2c_address" => "0x04", "pin" => 3, "servo" => 60 }
      device.transform_input_message(message)
      expect(message["servo"]).to eq(60)
    end
  end

  describe '#slave_device_information' do
    it 'gets the information' do
      device.save
      slave_device = FactoryBot.create(:device, device_id: device.id, i2c_address: '0x04')
      slave_pin_3 = FactoryBot.create(:pin, pin_number: 3, device: slave_device, pin_type: 'input')
      slave_pin_5 = FactoryBot.create(:pin, pin_number: 5, device: slave_device, pin_type: 'input')
      slave_pin_7 = FactoryBot.create(:pin, pin_number: 7, device: slave_device, pin_type: 'servo')
      expect(device.slave_device_information).to eq([{ i2c_address: '0x04', input_pins: [3, 5] }])
    end
  end

  describe '#input_pins' do
    it 'gets input pins' do
      device.save
      pin_3 = FactoryBot.create(:pin, pin_number: 3, device: device, pin_type: 'input')
      pin_5 = FactoryBot.create(:pin, pin_number: 5, device: device, pin_type: 'input')
      pin_7 = FactoryBot.create(:pin, pin_number: 7, device: device, pin_type: 'servo')
      expect(device.input_pins.collect(&:pin_number)).to eq([3, 5])
    end
  end

  describe '#display_name' do
    it "uses the device's name" do
      expect(device.name).to_not eq(nil)
      expect(device.display_name).to eq(device.name)
    end

    it 'uses a generic display name if the device name is blank' do
      device.name = ''
      expect(device.display_name).to eq("Device ##{device.id}")
    end
  end

  describe '#slave_device' do
    it 'gets the slave device' do
      device2 = FactoryBot.create(:device, device: device)
      expect(device.slave_device).to eq(device2)
    end

    it 'returns self if no slave device' do
      expect(device.slave_device).to eq(device)
    end
  end

  describe '#master_device' do
    it 'gets the master device' do
      device2 = FactoryBot.create(:device, device: device)
      expect(device2.master_device).to eq(device)
    end

    it 'returns self if no parent device' do
      expect(device.master_device).to eq(device)
    end
  end

  describe '#parent_device' do
    it 'gets the parent device' do
      device2 = FactoryBot.create(:device, device: device)
      expect(device2.parent_device).to eq(device)
    end

    it 'does not return self if no parent device' do
      expect(device.parent_device).to eq(nil)
    end
  end
end
