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
  belongs_to :device

  validates_uniqueness_of :auth_token
  validates_presence_of :device_id

  before_create :set_auth_token

  # remove leading and trailing whitespaces
  strip_attributes

  # get last update date of node.js install script
  def self.install_script_updated_at
    # get the git log results
    git_output = `git log -n1 app/views/shared/_nodejs_script.html.erb`
    # get the date portion of the results
    date_line = git_output.split("\n")[2]
    # get the date string
    date_string = date_line.split("Date:")[1].strip
    # output the parsed time
    return Time.parse(date_string)
  end

  # generate a secure authentication token
  def set_auth_token
    # generate the 6-character auth token
    self.auth_token = SecureRandom.base58(6)
    # regenerate if duplicate
    self.auth_token = self.set_auth_token if Registration.where(auth_token: auth_token).present?
    # return the auth token
    return self.auth_token
  end

end
