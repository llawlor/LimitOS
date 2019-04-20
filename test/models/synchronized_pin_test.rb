# == Schema Information
#
# Table name: synchronized_pins
#
#  id                 :bigint(8)        not null, primary key
#  pin_id             :integer
#  synchronization_id :integer
#  device_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  value              :string(255)
#

require 'test_helper'

class SynchronizedPinTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
