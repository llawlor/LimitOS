class DeviceChannel < ApplicationCable::Channel

  # called when someone subscribes to the device channel
  def subscribed
    # name of stream
    stream_from "device:X"
  end
end
