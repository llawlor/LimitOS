class Api::V1::DevicesController < ApplicationController
  skip_before_action :verify_authenticity_token

  # create a new device
  def create
    device = Device.create
    render plain: device.auth_token
  end

end
