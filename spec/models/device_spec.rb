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
#  invert_video           :boolean          default(FALSE)
#  video_enabled          :boolean          default(FALSE)
#  control_template       :string(255)
#  public                 :boolean          default(FALSE)
#  slug                   :string(255)
#

require 'rails_helper'

RSpec.describe Device, type: :model do
  before :each do
    allow_any_instance_of(Device).to receive(:broadcast_device_information).and_return(nil)
  end

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

  describe '#video_from_devices_url' do
    it 'includes the auth token' do
      device.save
      expect(device.video_from_devices_url).to eq("#{ Rails.application.config_for(:limitos)['video_from_devices_host'] }/video_from_devices/#{ device.auth_token }")
    end

    it 'should include the device id if the device is public' do
      device.save
      device.update(public: true)
      expect(device.video_from_devices_url).to eq("#{ Rails.application.config_for(:limitos)['video_from_devices_host'] }/video_from_devices/#{ device.id }")
    end
  end

  describe '#video_to_clients_url' do
    it 'includes the auth token' do
      device.save
      expect(device.video_to_clients_url).to eq("#{ Rails.application.config_for(:limitos)['video_to_clients_host'] }/video_to_clients/#{ device.auth_token }")
    end

    it 'should include the device id if the device is public' do
      device.save
      device.update(public: true)
      expect(device.video_to_clients_url).to eq("#{ Rails.application.config_for(:limitos)['video_to_clients_host'] }/video_to_clients/#{ device.id }")
    end
  end

  describe '#broadcast_device_information on create/update/destroy' do
    it 'sends on create' do
      expect_any_instance_of(Device).to receive(:broadcast_device_information).once
      device.save
    end

    it 'sends on update' do
      device.save
      expect_any_instance_of(Device).to receive(:broadcast_device_information).once
      device.update_attributes(name: 'newname')
    end

    it 'sends on destroy' do
      device.save
      expect_any_instance_of(Device).to receive(:broadcast_device_information).once
      device.destroy
    end
  end

  describe '#broadcast_device_information' do
    before :each do
      device.save
      allow_any_instance_of(Device).to receive(:broadcast_device_information).and_call_original
    end

    it 'broadcasts the message' do
      expect {
        device.broadcast_device_information
      }.to have_broadcasted_to(device.id).from_channel(DevicesChannel).with(hash_including({ slave_devices: [] }))
    end

    it 'broadcasts the message to the master device' do
      slave_device = FactoryBot.create(:device, device_id: device.id, i2c_address: '0x04')
      expect(slave_device.master_device).to eq(device)
      expect {
        slave_device.broadcast_device_information
      }.to have_broadcasted_to(device.id).from_channel(DevicesChannel).with(hash_including({ slave_devices: [{"i2c_address": '0x04',"input_pins": []}] }))
    end
  end

  describe '#broadcast_raw_message' do
    before :each do
      device.save
      allow_any_instance_of(Device).to receive(:broadcast_device_information).and_call_original
    end

    it 'broadcasts the message' do
      expect {
        device.broadcast_raw_message({ "some_key" => 'some_value' })
      }.to have_broadcasted_to(device.id).from_channel(DevicesChannel).with(hash_including({ some_key: 'some_value' }))
    end
  end

  describe '#broadcast_message' do
    before :each do
      device.save
    end

    it 'broadcasts the message' do
      expect {
        device.broadcast_message({ "pin" => '5', "servo" => '12' })
      }.to have_broadcasted_to(device.id).from_channel(DevicesChannel).with(hash_including({ pin: '5', servo: '12' }))
    end

    it 'adds the video url to a start_video command' do
      expect {
        device.broadcast_message({ 'command' => 'start_video' })
      }.to have_broadcasted_to(device.id).from_channel(DevicesChannel).with(hash_including({ video_url: device.video_from_devices_url }))
    end

    it 'broadcasts to another device' do
      device_2 = FactoryBot.create(:device)
      device.update_attributes(broadcast_to_device_id: device_2.id)
      expect {
        device.broadcast_message({ "pin" => '5', "servo" => '12' })
      }.to have_broadcasted_to(device_2.id).from_channel(DevicesChannel).with(hash_including({ pin: '5', servo: '12' }))
    end

    it 'broadcasts to another device and changes the i2c_address' do
      arduino_output_device = FactoryBot.create(:device, i2c_address: '0x05')
      arduino_input_device = FactoryBot.create(:device, device_id: device.id, broadcast_to_device_id: arduino_output_device.id, i2c_address: '0x04')
      expect {
        device.broadcast_message({ "pin" => '5', "servo" => '12', "i2c_address" => '0x04' })
      }.to have_broadcasted_to(arduino_output_device.id).from_channel(DevicesChannel).with(hash_including({ pin: '5', servo: '12', i2c_address: '0x05' }))
    end

    it 'returns false if the pin message is malformed' do
      expect(device.broadcast_message({ "pin" => '33INVALID', "servo" => '12' })).to eq(false)
    end
  end

  describe '#constrain_output_message' do
    before :each do
      device.save
    end

    it 'constrains the minimum' do
      pin = FactoryBot.create(:pin, pin_number: 3, device: device, pin_type: 'input', min: 30)
      message = { "i2c_address" => "0x04", "pin" => 3, "servo" => 10 }
      device.constrain_output_message(message)
      expect(message["servo"]).to eq(30)
    end

    it 'constrains the maximum' do
      pin = FactoryBot.create(:pin, pin_number: 3, device: device, pin_type: 'input', max: 30)
      message = { "i2c_address" => "0x04", "pin" => 3, "servo" => 50 }
      device.constrain_output_message(message)
      expect(message["servo"]).to eq(30)
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

    it 'transforms decimal rounding correctly' do
      pin = FactoryBot.create(:pin, pin_number: 3, device: device, pin_type: 'input', transform: 'round(7.3, 1)')
      message = { "i2c_address" => "0x04", "pin" => 3, "servo" => 60 }
      device.transform_input_message(message)
      expect(message["servo"].to_s).to eq('7.3')
      expect(message["pin"]).to eq(3)
    end

    it 'transforms whole number rounding correctly' do
      pin = FactoryBot.create(:pin, pin_number: 3, device: device, pin_type: 'input', transform: 'round(7.3, 0)')
      message = { "i2c_address" => "0x04", "pin" => 3, "servo" => 60 }
      device.transform_input_message(message)
      expect(message["servo"].to_s).to eq('7')
      expect(message["pin"]).to eq(3)
    end

    it 'transforms whole number rounding correctly if round is capitalized' do
      pin = FactoryBot.create(:pin, pin_number: 3, device: device, pin_type: 'input', transform: 'ROUND(7.3, 0)')
      message = { "i2c_address" => "0x04", "pin" => 3, "servo" => 60 }
      device.transform_input_message(message)
      expect(message["servo"].to_s).to eq('7')
      expect(message["pin"]).to eq(3)
    end

    it 'transforms whole number rounding correctly if no space after the comma' do
      pin = FactoryBot.create(:pin, pin_number: 3, device: device, pin_type: 'input', transform: 'round(7.3,0)')
      message = { "i2c_address" => "0x04", "pin" => 3, "servo" => 60 }
      device.transform_input_message(message)
      expect(message["servo"].to_s).to eq('7')
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
