class DevicesChannel < ApplicationCable::Channel

  # called when someone subscribes to the device channel
  def subscribed
    # name of stream
    stream_from "devices:X"
  end
end
