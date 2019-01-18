# == Schema Information
#
# Table name: synchronizations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  device_id  :integer
#  messages   :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Synchronization < ApplicationRecord
  has_many :synchronized_pins
end
