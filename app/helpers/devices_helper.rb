module DevicesHelper

  # host with port for video coming from devices
  def video_from_devices_url
    return Rails.env.production? ? 'wss://limitos.com' : 'ws://192.168.1.101:8081'
  end

  # url for the websocket server
  def websocket_server_url
    return Rails.env.production? ? 'wss://limitos.com/cable' : "ws://#{request.host}:#{request.port}/cable"
  end

end
