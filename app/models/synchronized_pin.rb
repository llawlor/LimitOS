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
#

class SynchronizedPin < ApplicationRecord
end
