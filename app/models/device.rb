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
#

# device_type can be 'raspberry_pi' or 'arduino'
class Device < ApplicationRecord
  has_secure_token :auth_token
  
  validates_presence_of :name, :device_type, :user_id

  belongs_to :user
  belongs_to :device, optional: true
  has_many :devices
  has_many :pins

  # options for device type
  DEVICE_TYPES = ['raspberry_pi', 'arduino']

  # alias for device.device
  def parent_device
    self.device
  end
end
