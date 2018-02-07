class Api::V1::DevicesController < ApplicationController
  skip_before_action :verify_authenticity_token

  # create a new device
  def create
    # create the anonymous device
    device = Device.create
    # output the auth_token
    render plain: device.to_json
  end

end
