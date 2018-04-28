class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :get_devices

  # sets the @devices variable from the user account or the cookies
  def get_devices
    # if the user is logged in
    if current_user.present?
      @devices = current_user.devices
    # else get the devices from the cookies
    else
      # get the device ids from the cookie
      device_ids = cookies.encrypted[:device_ids]
      # get the devices without users that match the ids
      @devices = Device.where(user_id: nil).where(id: device_ids)
    end
  end

end
