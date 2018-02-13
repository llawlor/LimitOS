class SynchronizationsController < ApplicationController
  before_action :get_device
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

    def set_synchronization
      @synchronization = @device.synchronizations.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def synchronization_params
      params.require(:synchronization).permit(:device_id, :name, :messages)
    end

end
