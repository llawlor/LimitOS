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

  validates_presence_of :device_id

  after_save :send_slave_device_information
  after_destroy :send_slave_device_information

  # remove leading and trailing whitespaces
  strip_attributes
  
  # options for pin type
  PIN_TYPES = ['input', 'servo', 'digital']

  private

    # send slave device information via the master device
    def send_slave_device_information
      # broadcast the slave device information
      self.device.broadcast_slave_device_information
    end

end
