class SynchronizationsController < ApplicationController

  before_action :set_device
  before_action :set_synchronization, only: [:show, :edit, :update, :destroy]

  # new synchronization
  def new
    @synchronization = Synchronization.new
  end

  # edit a synchronization
  def edit
  end

  # create the synchronization
  def create
    @synchronization = @device.synchronizations.new(synchronization_params)

    if @synchronization.save
      redirect_to @device, notice: 'synchronization was successfully created.'
    else
      frender :new
    end
  end

  # update a synchronization
  def update
    if @synchronization.update(synchronization_params)
      redirect_to @device, notice: 'synchronization was successfully updated.'
    else
      render :edit
    end
  end

  # delete a synchronization
  def destroy
    @synchronization.destroy
    redirect_to @device, notice: 'synchronization was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = current_user.devices.find(params[:device_id])
    end

    def set_synchronization
      @synchronization = @device.synchronizations.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def synchronization_params
      params.require(:synchronization).permit(:device_id, :name, :message)
    end

end
