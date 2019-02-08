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

  # get the opposite value for a pin
  def opposite_value
    # if the value is 'on'
    if value == 'on'
      return 'off'
    # else if the value is 'off'
    elsif value == 'off'
      return 'on'
    # else if the value is a number greater than 0
    elsif value.to_i > 0
      return '0'
    # return nothing by default
    else
      return nil
    end
  end
end
