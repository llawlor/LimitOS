class Api::V1::RegistrationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  # create a new registration
  def create
    # get the device
    device = Device.find_by(id: params[:device_id])

    # error if invalid
    render plain: { error: 'Invalid device credentials.' } and return if device.blank?

    # check the authentication
    valid = true if Devise.secure_compare(device.auth_token, params[:auth_token])

    # error if invalid
    render plain: { error: 'Invalid device credentials.' } and return if valid != true

    # create the registration
    registration = device.registrations.create(expires_at: 5.minutes.from_now)

    # output the auth_token
    render plain: registration.to_json
  end

end
