class PinsController < ApplicationController
  before_action :set_device
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

    respond_to do |format|
      if @pin.save
        format.html { redirect_to @device, notice: 'Pin was successfully created.' }
        format.json { render :show, status: :created, location: @device }
      else
        format.html { render :new }
        format.json { render json: @pin.errors, status: :unprocessable_entity }
      end
    end
  end

  # update a pin
  def update
    respond_to do |format|
      if @pin.update(pin_params)
        format.html { redirect_to @pin, notice: 'Pin was successfully updated.' }
        format.json { render :show, status: :ok, location: @pin }
      else
        format.html { render :edit }
        format.json { render json: @pin.errors, status: :unprocessable_entity }
      end
    end
  end

  # delete a pin
  def destroy
    @pin.destroy
    respond_to do |format|
      format.html { redirect_to pins_url, notice: 'Pin was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = current_user.devices.find(params[:device_id])
    end

    def set_pin
      @pin = @device.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pin_params
      params.require(:pin).permit(:device_id, :name, :pin_type, :pin_number, :min, :max)
    end
end
