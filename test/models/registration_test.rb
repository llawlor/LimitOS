# == Schema Information
#
# Table name: registrations
#
#  id         :integer          not null, primary key
#  auth_token :string(6)
#  device_id  :integer
#  expires_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class RegistrationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
