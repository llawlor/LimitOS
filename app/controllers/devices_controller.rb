class DevicesController < ApplicationController

  # send a message to the device
  # params[:message] should be a hash
  def send_message
    # broadcast to "device:X"
    DevicesChannel.broadcast_to(
      'X',
      params[:message]
    )
    head :ok
  end

end
