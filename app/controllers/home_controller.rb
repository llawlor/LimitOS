class HomeController < ApplicationController

  def index; ; end

  def on
    puts 'on controller'
    # broadcast to "device:X"
    DevicesChannel.broadcast_to(
      'X',
      my_message: 'on'
    )
  end

  def off
    puts 'off controller'
    # broadcast to "device:X"
    DevicesChannel.broadcast_to(
      'X',
      my_message: 'off'
    )
  end

end
