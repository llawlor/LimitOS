class HomeController < ApplicationController

  # homepage
  def index
    # associate devices if necessary
    associate_devices_with_user if current_user.present? && cookies.encrypted[:device_ids].present?
  end

  private

    # associate devices with this user
    def associate_devices_with_user
      # get the device ids from the cookie
      device_ids = cookies.encrypted[:device_ids]
      # get the devices without users that match the ids
      new_devices = Device.where(user_id: nil).where(id: device_ids)
      # add the devices
      new_devices.update_all(user_id: current_user.id)
      # remove the cookie
      cookies.delete(:device_ids)
    end

end
