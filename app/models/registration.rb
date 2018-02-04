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

class Registration < ApplicationRecord

  validates_uniqueness_of :auth_token

  # generate a secure authentication token
  def generate_auth_token
    # generate the 6-character auth token
    auth_token = SecureRandom.base58(6)
    # regenerate if duplicate
    auth_token = self.generate_auth_token if Registration.where(auth_token: auth_token).present?
    # return the auth token
    return auth_token
  end

end
