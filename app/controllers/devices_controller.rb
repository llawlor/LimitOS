class DevicesController < ApplicationController
  before_action :get_device, only: [:show, :edit, :update, :destroy, :nodejs_script, :arduino_script, :setup, :embed]
  before_action :get_parent_device, only: [:new]
  skip_before_action :verify_authenticity_token, only: [:install]

  # embed video in another page
  def embed
    render plain: 'embed'
  end

  # setup and help page
  def setup
    @parent_device = @devices.find(@device.device_id) if @device.device_id.present?
    @master_device = @device.master_device
  end

  # register a new device (take ownership of it)
  def submit_registration
    # get the registration
    registration = Registration.where(auth_token: params[:registration][:auth_token]).where("expires_at > ?", DateTime.now).first

    # error if the registration does not exist
    if registration.blank?
      flash[:error] = 'Invalid or expired registration code. Please reinstall LimitOS on your Raspberry Pi.'
      redirect_to register_path and return
    end

    # error if the device is already registered
    if registration.device.user_id.present?
      flash[:error] = 'Device has already been registered.'
      redirect_to register_path and return
    end

    # add a flash notice
    flash[:notice] = 'Your device has been registered.'

    # update the device to be a raspberry pi
    registration.device.update_attributes(device_type: 'raspberry_pi')

    # if the user is logged in
    if current_user.present?
      # assign ownership of the device
      registration.device.update_attributes(user_id: current_user.id)
      # remove the registration
      registration.destroy

      # redirect to the user's devices page
      redirect_to edit_device_path(registration.device) and return
    # else no user
    else
      # save this device to the logged out user
      save_device_to_cookie(registration.device.id)
      # remove the registration
      registration.destroy
      # redirect to the device page
      redirect_to edit_device_path(registration.device) and return
    end

  end

  # registration page
  def register
    @registration = Registration.new
  end

  # create the dynamic raspberry pi setup script
  def install
    # if this is for a specific device
    if params[:id].present? && params[:auth_token].present?
      # get the device
      unauthorized_device = Device.find(params[:id])
      # if the device is authenticated
      @device = unauthorized_device if Devise.secure_compare(unauthorized_device.auth_token, params[:auth_token])
    end

    # use a text template but don't use a layout
    render '/devices/_install.text.erb', layout: false, content_type: 'text/plain'
  end

  # pretty print the install script
  def pretty_print_install; ; end

  # create the dynamic arduino script
  def arduino_script
    # don't use a layout
    render layout: false
  end

  # create the dynamic nodejs script
  def nodejs_script
    # don't use a layout
    render layout: false
  end

  # send a message to the device
  # params[:message] should be a hash
  def send_message
    # get the device
    device = Device.find_by(id: params[:id])

    # return false if no device
    render plain: 'Unauthorized' and return if device.blank?

    # return false if auth_token doesn't match
    render plain: 'Unauthorized' and return if !Devise.secure_compare(device.auth_token, params[:auth_token])

    # broadcast to the device
    device.broadcast_message(params[:message])

    # blank response
    head :ok
  end

  # list all devices
  def index
  end

  # show a particular device
  def show
    @parent_device = @devices.find(@device.device_id) if @device.device_id.present?
    @master_device = @device.master_device
  end

  # new device
  def new
    # get the parent device
    @parent_device = @devices.find(params[:device_id]) if params[:device_id].present?
    # default new device
    @device = Device.new
    # set to arduino if necessary
    @device.device_type = 'arduino' if params[:device_type] == 'arduino'
  end

  # edit a device
  def edit
  end

  # create a device
  def create
    # if the user is logged in
    if current_user.present?
      @device = current_user.devices.new(device_params)
    # else the user is logged out
    else
      @device = Device.new(device_params)
    end

    # add the parent device if it exists
    if params[:parent_device_id].present?
      @parent_device = @devices.find(params[:parent_device_id] )
      @device.device_id = @parent_device.id
    end

    # don't allow broadcast_to_id to be set on create
    @device.broadcast_to_device_id = nil

    # if the device was saved
    if @device.save
      # if the user is logged out, add the device
      save_device_to_cookie(@device.id) if current_user.blank?
      # redirect to the device
      redirect_to @device, notice: 'Device was successfully created.'
    else
      render :new
    end
  end

  # update a device
  def update
    # get the broad_cast_to_device
    broadcast_to_device = Device.find_by(id: device_params[:broadcast_to_device_id]) if device_params[:broadcast_to_device_id].present?

    # if there is a user
    if current_user.present?
      # error if the broadcast_to_device is not owned by the current user
      render plain: 'Unauthorized' and return if broadcast_to_device.present? && broadcast_to_device.user != current_user
    # else no user logged in
    else
      # error if the broadcast_to_device and device aren't both in @devices
      render plain: 'Unauthorized' and return if broadcast_to_device.present? && !@devices.include?(broadcast_to_device)
    end

    # if the device was updated successfully
    if @device.update(device_params)
      redirect_to @device, notice: 'Device was successfully updated.'
    # else the device was not updated
    else
      render :edit
    end
  end

  # delete a device
  def destroy
    @device.destroy
    redirect_to devices_url, notice: 'Device was successfully destroyed.'
  end

  private

    # get the device for users that are logged in or out
    def get_device
      # exit if no id in the params
      return true if params[:id].blank?

      # if the user is logged in
      if current_user.present?
        @device = current_user.devices.find_by(id: params[:id])
      # else the user is not logged in
      else
        @device = @devices.find_by(id: params[:id])
      end

      # output message if no device
      render plain: 'No device' and return if @device.blank?
    end

    # get the parent device
    def get_parent_device
      # exit if no device_id in the params
      return true if params[:device_id].blank?

      # if the user is logged in
      if current_user.present?
        @parent_device = current_user.devices.find(params[:device_id])
      # else the user is not logged in
      else
        @parent_device = @devices.find_by(id: params[:device_id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      params.fetch(:device, {}).permit(:name, :device_type, :i2c_address, :broadcast_to_device_id, :video_enabled, :invert_video)
    end

    # save this device to the logged out user
    def save_device_to_cookie(device_id)
      # get the device ids or set to an empty array
      device_ids = cookies.encrypted[:device_ids].present? ? cookies.encrypted[:device_ids] : []
      # append the new id to the array
      device_ids << device_id
      # set the new cookie value
      cookies.encrypted[:device_ids] = { value: device_ids, expires: 1.year.from_now }
    end

end
