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
#

# device_type can be 'raspberry_pi' or 'arduino'

# control_template can be: 'drive'
class Device < ApplicationRecord
  has_secure_token :auth_token

  belongs_to :user, optional: true
  belongs_to :device, optional: true
  belongs_to :broadcast_to_device, class_name: 'Device', foreign_key: 'broadcast_to_device_id', optional: true
  has_many :devices
  has_many :pins, dependent: :destroy
  has_many :synchronizations, dependent: :destroy
  has_many :registrations, dependent: :destroy

  after_save :broadcast_device_information
  after_destroy :broadcast_device_information

  # remove leading and trailing whitespaces
  strip_attributes

  # options for device type
  DEVICE_TYPES = ['raspberry_pi', 'arduino']

  # name that is displayed for a device
  def display_name
    self.name.present? ? self.name : "Device ##{self.id}"
  end

  # alias for device.device
  def parent_device
    self.device
  end

  # parent device or self
  def master_device
    self.parent_device.present? ? self.parent_device : self
  end

  # slave device or self
  def slave_device
    self.devices.present? ? self.devices.first : self
  end

  # get version of node.js install script
  def self.install_script_version
    # return the version, stored in config/limitos.yml
    return Rails.application.config_for(:limitos)["limitos_client_version"]
  end

  # full url for video coming from devices
  # in the future, this method can return dynamic values based on additional servers
  def video_from_devices_url
    # return the full url
    return "#{ Rails.application.config_for(:limitos)['video_from_devices_host'] }/video_from_devices/#{self.auth_token}"
  end

  # full url for video going to clients
  # in the future, this method can return dynamic values based on additional servers
  def video_to_clients_url
    # return the full url
    return "#{ Rails.application.config_for(:limitos)['video_to_clients_host'] }/video_to_clients/#{self.auth_token}"
  end

  # digital pins
  def digital_pins
    # if this is a raspberry pi
    if self.device_type == 'raspberry_pi'
      # get input or digital pins
      self.pins.where("pin_type = 'digital' or pin_type = 'input'")
    # else just get the digital pins
    else
      self.pins.where("pin_type = 'digital'")
    end
  end

  # analog pins
  def analog_pins
    # if this is an arduino
    if self.device_type == 'arduino'
      # get servo or input pins
      self.pins.where("pin_type = 'servo' or pin_type = 'input'")
    # else just get the servo pins
    else
      self.pins.where("pin_type = 'servo'")
    end
  end

  # get the slave devices as an array, for example: [{ i2c_address: '0x04', input_pins: [3, 4, 5]}]
  def slave_device_information
    # output array
    output = []

    # for each slave device
    self.devices.each do |device|
      # append the data to the array
      output << { i2c_address: device.i2c_address, input_pins: device.input_pins.collect(&:pin_number) }
    end

    # return the array
    return output
  end

  # get only the input pins
  def input_pins
    self.pins.where(pin_type: 'input')
  end

  # send device information
  def broadcast_device_information
    # broadcast the message to the master device
    self.master_device.broadcast_raw_message({ input_pins: self.master_device.input_pins.collect(&:pin_number), slave_devices: self.master_device.slave_device_information })
  end

  # send a raw message to the device, without any additional message manipulation
  def broadcast_raw_message(message)
    DevicesChannel.broadcast_to(
      self.id,
      message
    )
  end

  # transform the input message (should be invoked on the input/sending device)
  def transform_input_message(message)
    # get the input pin
    input_pin = self.pins.find_by(pin_number: message["pin"].to_i)

    # translate to a different output pin if necessary
    message["pin"] = input_pin.output_pin_number if input_pin.try(:output_pin_number).present?

    # if there is a transform
    if input_pin.present? && input_pin.transform.present?
      # initialize the calculator
      calculator = Dentaku::Calculator.new

      # if there is a servo message
      if message["servo"].present?
        # get the transformed message
        output = calculator.evaluate(input_pin.transform, x: message["servo"].to_f)
        # set the output as an integer if the transform is meant to do that; matches "round(" at beginning of string and ", 0" at end of string
        # gets around a problem with Dentaku where calculator.evaluate("round(3.3, 0)") returns #<BigDecimal:3011e60,'0.3E1',9(27)> instead of 3
        output = output.to_i if !!(input_pin.transform =~ /\Around\(/i) && !!(input_pin.transform =~ /,\s?0\)\z/)
        # set the servo message
        message["servo"] = output
      end
    end

    # return the message
    return message
  end

  # constrain the output message (should be invoked on the target device, which may be a slave)
  def constrain_output_message(message)
    # get the output pin
    output_pin = self.pins.find_by(pin_number: message["pin"].to_i)

    # don't go lower than the minimum
    message["servo"] = output_pin.min if output_pin.try(:min).present? && message["servo"].to_i < output_pin.min

    # don't go higher than the maximum
    message["servo"] = output_pin.max if output_pin.try(:max).present? && message["servo"].to_i > output_pin.max

    # return the message
    return message
  end

  # broadcasts a message
  def broadcast_message(message)
    # exit if the data is malformed (pin is not a number)
    return false if message.keys.include?("pin") && (message["pin"].to_s != message["pin"].to_i.to_s)

    # if the i2c_address is present get the slave, otherwise return the parent
    input_device = (message["i2c_address"].present? ? self.devices.find_by(i2c_address: message["i2c_address"]) : self)

    # if we should broadcast to another device (which may be a slave)
    target_device = (input_device.broadcast_to_device.present? ? input_device.broadcast_to_device : self)

    # remove the action portion of the message if it's present
    message.delete("action") if message["action"].present?

    # transform the message
    message = input_device.transform_input_message(message)

    # constrain the message
    message = target_device.constrain_output_message(message)

    # change the i2c_address to the target_device's i2c_address
    message["i2c_address"] = target_device.i2c_address if target_device.i2c_address.present?

    # if this is a start video command
    if message['command'].present? && message['command'] == 'start_video'
      # add the video url
      message['video_url'] = self.video_from_devices_url
    end

    # broadcast to the target device's master (since we can't broadcast directly to a slave)
    DevicesChannel.broadcast_to(
      target_device.master_device.id,
      message.merge({ time: (Time.now.to_f * 1000).to_i })
    )
  end

end
