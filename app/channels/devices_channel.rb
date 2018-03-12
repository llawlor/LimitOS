class DevicesChannel < ApplicationCable::Channel

  # called when someone subscribes to the device channel
  def subscribed
    # if no id, then just return true
    return true if params[:id].blank?

    # get the device
    device = Device.find(params[:id])

    # stream only if the auth_token matches
    stream_from "devices:#{device.id}" if Devise.secure_compare(device.auth_token, params[:auth_token])
  end

  # receive input
  def receive(input_data)
    # get the device
    device = Device.find(params[:id])

    # if the auth_token matches
    if Devise.secure_compare(device.auth_token, params[:auth_token])
      # broadcast to the device
      DevicesChannel.broadcast_to(
        device.id,
        input_data.merge({ time: (Time.now.to_f * 1000).to_i })
      )
    end
  end
end
