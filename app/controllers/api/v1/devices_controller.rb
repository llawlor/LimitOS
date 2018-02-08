class Api::V1::DevicesController < ApplicationController
  skip_before_action :verify_authenticity_token

  # create a new device
  def create
    # create the anonymous device
    device = Device.create
    # output the auth_token
    render plain: device.to_json
  end

  # create the dynamic nodejs script
  def nodejs_script
    # get the device
    @device = Device.find_by(id: params[:id])

    # error if invalid
    render plain: { error: 'Invalid device credentials.' } and return if @device.blank?

    # check the authentication
    valid = true if Devise.secure_compare(@device.auth_token, params[:auth_token])

    # error if invalid
    render plain: { error: 'Invalid device credentials.' } and return if valid != true

    # set the websocket server url
    @websocket_server_url = Rails.env.production? ? 'wss://limitos.com/cable' : "ws://#{request.host}:#{request.port}/cable"

    # don't use a layout
    render partial: 'shared/nodejs_script', layout: false, content_type: 'text/plain'
  end

end
