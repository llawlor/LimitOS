class ControlController < ApplicationController
  before_action :get_device

  # show the controls page
  def show

  end


  private

    # get the device for users that are logged in or out
    def get_device
      # exit if no id in the params
      return true if params[:slug].blank?

      # if the user is logged in
      if current_user.present?
        @device = current_user.devices.find_by(id: params[:slug])
      # else the user is not logged in
      else
        @device = @devices.find_by(id: params[:slug])
      end

      # output message if no device
      render plain: 'No device' and return if @device.blank?
    end

end
