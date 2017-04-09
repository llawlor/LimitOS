class DevicesController < ApplicationController
  before_action :set_device, only: [:show, :edit, :update, :destroy]

  # send a message to the device
  # params[:message] should be a hash
  def send_message
    # broadcast to "device:X"
    DevicesChannel.broadcast_to(
      'X',
      params[:message].merge({ time: (Time.now.to_f * 1000).to_i })
    )
    head :ok
  end

  # list all devices
  def index
    @devices = current_user.devices
  end

  # show a particular device
  def show
  end

  # new device
  def new
    @device = Device.new
  end

  # edit a device
  def edit
  end

  # create a device
  def create
    @device = current_user.devices.new(device_params)

    if @device.save
      redirect_to @device, notice: 'Device was successfully created.'
    else
      render :new
    end
  end

  # update a device
  def update
    if @device.update(device_params)
      redirect_to @device, notice: 'Device was successfully updated.'
    else
      :edit
    end
  end

  # delete a device
  def destroy
    @device.destroy
    redirect_to devices_url, notice: 'Device was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = current_user.devices.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      params.fetch(:device, {}).permit(:name, :device_type)
    end
end
