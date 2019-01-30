class ControlController < ApplicationController
  before_action :get_device_and_owner


  # update the controls
  def update
    # if the device was updated successfully
    if @device.update(device_params)

      # set synchronizations from parameters if this is a drive template
      @device.set_drive_synchronizations(params[:synchronizations]) if @device.control_template == 'drive'

      # redirect with a notice
      redirect_to @device.control_path, notice: 'Controls were successfully updated.'
    # else the device was not updated
    else
      render :edit
    end
  end

  # show the controls page
  def show
    # get the master device
    @master_device = @device.master_device

    # render the control layout
    render layout: 'control'
  end

  # edit the control page
  def edit
    # render the control layout
    render layout: 'control'
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      params.fetch(:device, {}).permit(:control_template, :public, :slug)
    end

    # get the device for users that are logged in or out, and determine whether the user is the owner
    def get_device_and_owner
      # exit if no id in the params
      return true if params[:slug].blank?

      # set the owner to false by default
      @owner = false

      # if the user is logged in
      if current_user.present?
        # get device by id
        @device = current_user.devices.find_by(id: params[:slug])
        # get device by slug
        @device = current_user.devices.find_by(slug: params[:slug]) if @device.blank? && params[:slug].present?
      # else the user is not logged in
      else
        # get device by id
        @device = @devices.find_by(id: params[:slug])
        # get device by slug
        @device = @devices.find_by(slug: params[:slug]) if @device.blank? && params[:slug].present?
      end

      # set the owner status
      @owner = true if @device.present?

      # if there is no device
      if @device.blank?
        # get the unauthorized device by id
        unauthorized_device = Device.find_by(id: params[:slug])
        # get the unauthorized device by slug
        unauthorized_device = Device.find_by(slug: params[:slug]) if unauthorized_device.blank? && params[:slug].present?

        # get the device if it's public
        @device = unauthorized_device if unauthorized_device.public?
      end

      # output message if no device
      render plain: 'No device' and return if @device.blank?
    end

end
