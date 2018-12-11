module DevicesHelper

  # url for the websocket server
  def websocket_server_url
    return Rails.env.production? ? 'wss://limitos.com/cable' : "ws://#{request.host}:#{request.port}/cable"
  end

end
