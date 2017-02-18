class DevicesController < ApplicationController

  # send a message to the device
  def send_message
    # broadcast to "device:X"
    DevicesChannel.broadcast_to(
      'X',
      my_message: params[:message]
    )
  end

end
