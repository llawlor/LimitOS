# == Schema Information
#
# Table name: synchronizations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  device_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Synchronization < ApplicationRecord
  has_many :synchronized_pins
  has_many :pins, through: :synchronized_pins
end
