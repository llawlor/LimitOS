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

class Pin < ApplicationRecord
  belongs_to :device
  has_many :synchronized_pins

  validates_presence_of :device_id

  after_save :send_device_information
  after_destroy :send_device_information

  # remove leading and trailing whitespaces
  strip_attributes

  # options for digital pin type
  DIGITAL_PIN_TYPES = {
    input: 'input - digital',
    digital: 'output - digital'
  }

  # options for analog pin type
  ANALOG_PIN_TYPES = {
    input: 'input - digital or analog',
    digital: 'output - digital',
    servo: 'output - servo or motor'
  }

  # get the appropriate pin type has based on the device type
  def pin_types
    # return the digital pin types if this is a raspberry pi
    return DIGITAL_PIN_TYPES if self.device.device_type == 'raspberry_pi'
    # else return the analog pin types
    return ANALOG_PIN_TYPES
  end

  # display the pin type
  def display_pin_type
    # empty string if no pin type
    return '' if self.pin_type.blank?

    # get the display value from the hash key
    return self.pin_types[self.pin_type.to_sym]
  end

  private

    # send device information via the master device
    def send_device_information
      # broadcast the device information
      self.device.broadcast_device_information
    end

end
