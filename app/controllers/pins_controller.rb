class PinsController < ApplicationController
  before_action :get_device
  before_action :set_pin, only: [:show, :edit, :update, :destroy]

  # new pin
  def new
    @pin = Pin.new
  end

  # edit a pin
  def edit
  end

  # create the pin
  def create
    @pin = @device.pins.new(pin_params)

    if @pin.save
      redirect_to @device, notice: 'Pin was successfully created.'
    else
      frender :new
    end
  end

  # update a pin
  def update
    if @pin.update(pin_params)
      redirect_to @device, notice: 'Pin was successfully updated.'
    else
      render :edit
    end
  end

  # delete a pin
  def destroy
    @pin.destroy
    redirect_to @device, notice: 'Pin was successfully destroyed.'
  end

  private
  # get the device for users that are logged in or out
  def get_device
    # if the user is logged in
    if current_user.present?
      @device = current_user.devices.find(params[:device_id])
    # else the user is not logged in
    else
      @device = @devices.find_by(id: params[:device_id])
    end
  end

    def set_pin
      @pin = @device.pins.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pin_params
      params.require(:pin).permit(:device_id, :name, :pin_type, :pin_number, :min, :max, :transform)
    end
end
