class ControlController < ApplicationController
  before_action :get_device


  # update the controls
  def update
    # if the device was updated successfully
    if @device.update(device_params)
      redirect_to "/control/#{@device.id}", notice: 'Device was successfully updated.'
    # else the device was not updated
    else
      :edit
    end
  end

  # show the controls page
  def show
    @master_device = @device.master_device

    render layout: 'control'
  end

  # edit the control page
  def edit
    render layout: 'control'
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def device_params
    params.fetch(:device, {}).permit(:control_template, :public)
  end

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
