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

# device_type can be 'raspberry_pi' or 'arduino'
class Device < ApplicationRecord
  has_secure_token :auth_token

  belongs_to :user, optional: true
  belongs_to :device, optional: true
  belongs_to :broadcast_to_device, class_name: 'Device', foreign_key: 'broadcast_to_device_id', optional: true
  has_many :devices
  has_many :pins, dependent: :destroy
  has_many :synchronizations, dependent: :destroy
  has_many :registrations, dependent: :destroy

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

  # transform the input message (should be invoked on the input/sending device)
  def transform_input_message(message)
    # get the input device
    input_device = message["i2c_address"].present? ? self.devices.find_by(i2c_address: message["i2c_address"]) : self

    # get the input pin
    input_pin = input_device.pins.find_by(pin_number: message["pin"].to_i) if input_device.present?

    # translate to a different output pin if necessary
    message["pin"] = input_pin.output_pin_number if input_pin.try(:output_pin_number).present?

    # if there is a transform
    if input_pin.present? && input_pin.transform.present?
      # initialize the calculator
      calculator = Dentaku::Calculator.new

      # transform if there is a servo message
      message["servo"] = calculator.evaluate(input_pin.transform, x: message["servo"].to_i) if message["servo"].present?
    end

    # return the message
    return message
  end

  # constrain the output message (should be invoked on the target device)
  def constrain_output_message(message)
    # get the output device which may be a slave, and different than the target device
    output_device = message["i2c_address"].present? ? self.devices.find_by(i2c_address: message["i2c_address"]) : self

    # get the output pin
    output_pin = output_device.pins.find_by(pin_number: message["pin"].to_i)

    # don't go lower than the minimum
    message["servo"] = output_pin.min if output_pin.try(:min).present? && message["servo"].to_i < output_pin.min

    # don't go higher than the maximum
    message["servo"] = output_pin.max if output_pin.try(:max).present? && message["servo"].to_i > output_pin.max

    # return the message
    return message
  end

  # broadcasts a message
  def broadcast_message(message)
    # if we should broadcast to another device
    target_device = self.broadcast_to_device.present? ? self.broadcast_to_device : self

    # remove the action portion of the message if it's present
    message.delete("action") if message["action"].present?

    # transform the message
    message = self.transform_input_message(message)

    # constrain the message
    message = target_device.constrain_output_message(message)

    # broadcast to the target device
    DevicesChannel.broadcast_to(
      target_device.id,
      message.merge({ time: (Time.now.to_f * 1000).to_i })
    )
  end

end
