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

# device_type can be 'raspberry_pi' or 'arduino'
class Device < ApplicationRecord
  belongs_to :user
  belongs_to :device, optional: true
  has_many :devices

end
