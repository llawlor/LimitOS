# == Schema Information
#
# Table name: synchronized_pins
#
#  id                 :integer          not null, primary key
#  pin_id             :integer
#  synchronization_id :integer
#  device_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  value              :string(255)
#

class SynchronizedPin < ApplicationRecord
  belongs_to :synchronization
  belongs_to :pin
  belongs_to :device
end
