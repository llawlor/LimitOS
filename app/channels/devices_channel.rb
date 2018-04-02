class DevicesChannel < ApplicationCable::Channel

  # called when someone subscribes to the device channel
  def subscribed
    # reject if no id
    reject and return if params[:id].blank?

    # get the device
    device = Device.find_by(id: params[:id])

    # reject if no device
    reject and return if device.blank?

    # reject if incorrect auth token
    reject and return if !Devise.secure_compare(device.auth_token, params[:auth_token])

    # start the stream
    stream_from "devices:#{device.id}"
  end

  # receive input
  def receive(input_data)
    # get the device
    device = Device.find_by(id: params[:id])

    # return false if no device
    return false if device.blank?

    # return false if auth_token doesn't match
    return false if !Devise.secure_compare(device.auth_token, params[:auth_token])

    # broadcast to the device
    device.broadcast_message(input_data)
  end
end
