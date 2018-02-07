class Api::V1::RegistrationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  # create a new registration
  def create
    # get the device (DON'T USE: vulnerable to timing attacks)
    #device = Device.find_by(auth_token: params[:auth_token])
    # output the auth_token
    render plain: device.auth_token
  end

end
