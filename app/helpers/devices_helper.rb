module DevicesHelper

  # url for the websocket server
  def websocket_server_url
    return Rails.env.production? ? 'wss://limitos.com/cable' : "ws://#{request.host}:#{request.port}/cable"
  end

  # linux shell command to reinstall the nodejs script
  def reinstall_script_command(device)
    return "curl -sS --data \"auth_token=#{ device.master_device.auth_token }\" #{ full_url }/devices/#{ device.master_device.id }/install | bash"
  end

end
