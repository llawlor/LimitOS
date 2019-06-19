module DevicesHelper

  # linux shell command to reinstall the nodejs script
  def reinstall_script_command(device)
    return "curl -sS --data \"auth_token=#{ device.master_device.auth_token }\" #{ full_server_url }/devices/#{ device.master_device.id }/run | bash"
  end

end
