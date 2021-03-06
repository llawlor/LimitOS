# == Schema Information
#
# Table name: devices
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  name                   :string(255)
#  device_id              :integer
#  device_type            :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  auth_token             :string(24)
#  i2c_address            :string(10)
#  broadcast_to_device_id :integer
#  invert_video           :boolean          default(FALSE)
#  video_enabled          :boolean          default(FALSE)
#  control_template       :string(255)
#  public                 :boolean          default(FALSE)
#  slug                   :string(255)
#  last_active_at         :datetime
#  public_video           :boolean          default(FALSE)
#  audio_enabled          :boolean          default(FALSE)
#  audio_start_pin        :integer
#  time_zone              :string(50)
#  sleeptime_start        :time
#  sleeptime_end          :time
#
class Device < ApplicationRecord
  has_secure_token :auth_token

  belongs_to :user, optional: true
  belongs_to :device, optional: true
  belongs_to :broadcast_to_device, class_name: 'Device', foreign_key: 'broadcast_to_device_id', optional: true
  has_many :devices
  has_many :pins, dependent: :destroy
  has_many :synchronizations, dependent: :destroy
  has_many :registrations, dependent: :destroy
  has_many :synchronized_pins, dependent: :destroy

  validate :validate_slug

  after_save :broadcast_device_information
  after_destroy :broadcast_device_information

  # remove leading and trailing whitespaces
  strip_attributes

  # options for device type
  DEVICE_TYPES = ['raspberry_pi', 'arduino']

  # options for the control template
  CONTROL_TEMPLATES = ['default', 'drive']

  # options for the "drive" control type
  DRIVE_CONTROL_TYPES = ['forward', 'backward', 'left', 'right']

  # device is currently online
  def online?
    # last active at exists, and is more recent than (status_interval + 3) seconds ago
    return (master_device.last_active_at.present? && (master_device.last_active_at > (Rails.application.config_for(:limitos)["status_interval"].to_i + 3).seconds.ago))
  end

  # devis is currently offline
  def offline?
    # opposite of online?
    return !master_device.online?
  end

  # add method to determine if a device is private
  def private?
    !self.public?
  end

  # determine if sleeptime is active
  def sleeptime_active?
    # false if timezone, start, or end is missing
    return false if time_zone.blank? || sleeptime_start.blank? || sleeptime_end.blank? || (sleeptime_start == sleeptime_end)

    # if start is before end
    if sleeptime_start < sleeptime_end
      # compare time portions only (ignoring dates)
      return (Time.now.in_time_zone(time_zone).strftime("%H%M%S") > sleeptime_start.strftime("%H%M%S")) && (Time.now.in_time_zone(time_zone).strftime("%H%M%S") < sleeptime_end.strftime("%H%M%S"))
    # else start should go past midnight until end
    else
      # compare time portions only (ignoring dates)
      return (Time.now.in_time_zone(time_zone).strftime("%H%M%S") > sleeptime_start.strftime("%H%M%S")) || (Time.now.in_time_zone(time_zone).strftime("%H%M%S") < sleeptime_end.strftime("%H%M%S"))
    end
  end

  # device to broadcast to
  def broadcast_to_device_or_self
    self.broadcast_to_device.present? ? self.broadcast_to_device : self
  end

  # path to the embed page
  def embed_path
    return "/embed/#{ self.slug || self.id }"
  end

  # path to the control page
  def control_path
    # if this is a drive template
    if control_template == 'drive'
      return "/drive/#{ self.slug || self.id }"
    # else default control page
    else
      return "/control/#{ self.slug || self.id }"
    end
  end

  # name that is displayed for a device
  def display_name
    self.name.present? ? self.name : "Device ##{self.id}"
  end

  # alias for device.device
  def parent_device
    self.device
  end

  # parent device or self
  def master_device
    self.parent_device.present? ? self.parent_device : self
  end

  # slave device or self
  def slave_device
    self.devices.present? ? self.devices.first : self
  end

  # set the "drive" control template synchronizations
  def set_drive_synchronizations(synchronization_params)
    # for each synchronization
    synchronization_params.each do |name, pin_mappings|

      # get the synchronization (or create it)
      synchronization = self.synchronizations.where(name: name).first_or_create

      # for each pin mapping
      pin_mappings.each do |pin_key, status|
        # get the pin id
        pin_id = pin_key.split('_')[1]

        # get the synchronized pin
        synchronized_pin = synchronization.synchronized_pins.find_by(device_id: self.id, pin_id: pin_id, value: 'on')

        # if the pin should be on
        if status == '1'
          # add the pin if it doesn't exist
          synchronization.synchronized_pins.create(device_id: self.id, pin_id: pin_id, value: 'on') if synchronized_pin.blank?
        # else the pin should be off
        else
          # remove the pin if it exists
          synchronized_pin.destroy if synchronized_pin.present?
        end

      end

    end
  end

  # get version of node.js install script
  def self.install_script_version
    # return the version, stored in config/limitos.yml
    return Rails.application.config_for(:limitos)["limitos_client_version"]
  end

  # full url for video coming from devices
  # in the future, this method can return dynamic values based on additional servers
  def video_from_devices_url(use_localhost = false)
    # set the unique id to the auth_token, or to the id if the device is public
    unique_id = (self.private? && !self.public_video) ? self.auth_token : self.id

    # get the video_from_devices_host
    video_from_devices_host = Rails.application.config_for(:limitos)['video_from_devices_host'];

    # override the host if this is development and use_localhost is true
    video_from_devices_host = 'ws://localhost:8081' if Rails.env.development? && (use_localhost == true)

    # return the full url
    return "#{ video_from_devices_host }/video_from_devices/#{ unique_id }"
  end

  # full url for video going to clients
  # in the future, this method can return dynamic values based on additional servers
  def video_to_clients_url
    # set the unique id to the auth_token, or to the id if the device is public
    unique_id = (self.private? && !self.public_video) ? self.auth_token : self.id

    # return the full url
    return "#{ Rails.application.config_for(:limitos)['video_to_clients_host'] }/video_to_clients/#{ unique_id }"
  end

  # full url for audio input
  # in the future, this method can return dynamic values based on additional servers
  def audio_input_url(use_localhost = false)
    # set the unique id to the auth_token, or to the id if the device is public
    unique_id = (self.private? && !self.public_video) ? self.auth_token : self.id

    # get the host
    audio_input_host = Rails.application.config_for(:limitos)['audio_input_host'];

    # override the host if this is development and use_localhost is true
    audio_input_host = 'ws://localhost:8083' if Rails.env.development? && (use_localhost == true)

    # return the full url
    return "#{ audio_input_host }/audio_input/#{ unique_id }"
  end

  # full url for audio output
  # in the future, this method can return dynamic values based on additional servers
  def audio_output_url
    # set the unique id to the auth_token, or to the id if the device is public
    unique_id = (self.private? && !self.public_video) ? self.auth_token : self.id

    # return the full url
    return "#{ Rails.application.config_for(:limitos)['audio_output_host'] }/audio_output/#{ unique_id }"
  end

  # digital pins
  def digital_pins
    # if this is a raspberry pi
    if self.device_type == 'raspberry_pi'
      # get input or digital pins
      self.pins.where("pin_type = 'digital' or pin_type = 'input'")
    # else just get the digital pins
    else
      self.pins.where("pin_type = 'digital'")
    end
  end

  # analog pins
  def analog_pins
    # if this is an arduino
    if self.device_type == 'arduino'
      # get servo or input pins
      self.pins.where("pin_type = 'servo' or pin_type = 'input'")
    # else just get the servo pins
    else
      self.pins.where("pin_type = 'servo'")
    end
  end

  # get the slave devices as an array, for example: [{ i2c_address: '0x04', input_pins: [3, 4, 5]}]
  def slave_device_information
    # output array
    output = []

    # for each slave device
    self.devices.each do |device|
      # append the data to the array
      output << { i2c_address: device.i2c_address, input_pins: device.input_pins }
    end

    # return the array
    return output
  end

  # returns an array of the input pin numbers
  def input_pins
    output = []

    # get input pins by default
    output = self.pins.where(pin_type: 'input').collect(&:pin_number)

    # add the audio_start_pin if necessary
    output << self.audio_start_pin if self.audio_enabled? && self.audio_start_pin.present?

    # return the output
    return output
  end

  # send device information
  def broadcast_device_information
    # construct the message
    message = { input_pins: self.master_device.input_pins, slave_devices: self.master_device.slave_device_information }
    # merge additional parameters if there is an audio pin
    message.merge!({ audio_start_pin: self.audio_start_pin, audio_input_url: self.broadcast_to_device_or_self.audio_input_url  }) if self.audio_enabled? && self.audio_start_pin.present?
    # broadcast the message to the master device
    self.master_device.broadcast_raw_message(message)
  end

  # send a raw message to the device, without any additional message manipulation
  def broadcast_raw_message(message)
    DevicesChannel.broadcast_to(
      self.id,
      message
    )
  end

  # transform the input message (should be invoked on the input/sending device)
  def transform_input_message(message)
    # get the input pin
    input_pin = self.pins.find_by(pin_number: message["pin"].to_i)

    # translate to a different output pin if necessary
    message["pin"] = input_pin.output_pin_number if input_pin.try(:output_pin_number).present?

    # if there is a transform
    if input_pin.present? && input_pin.transform.present?
      # initialize the calculator
      calculator = Dentaku::Calculator.new

      # if there is a servo message
      if message["servo"].present?
        # get the transformed message
        output = calculator.evaluate(input_pin.transform, x: message["servo"].to_f)
        # set the output as an integer if the transform is meant to do that; matches "round(" at beginning of string and ", 0" at end of string
        # gets around a problem with Dentaku where calculator.evaluate("round(3.3, 0)") returns #<BigDecimal:3011e60,'0.3E1',9(27)> instead of 3
        output = output.to_i if !!(input_pin.transform =~ /\Around\(/i) && !!(input_pin.transform =~ /,\s?0\)\z/)
        # set the servo message
        message["servo"] = output
      end
    end

    # return the message
    return message
  end

  # constrain the output message (should be invoked on the target device, which may be a slave)
  def constrain_output_message(message)
    # get the output pin
    output_pin = self.pins.find_by(pin_number: message["pin"].to_i)

    # don't go lower than the minimum
    message["servo"] = output_pin.min if output_pin.try(:min).present? && message["servo"].to_i < output_pin.min

    # don't go higher than the maximum
    message["servo"] = output_pin.max if output_pin.try(:max).present? && message["servo"].to_i > output_pin.max

    # return the message
    return message
  end

  # execute a synchronization
  def execute_synchronization(synchronization_id, opposite = false)
    # get the synchronization
    synchronization = self.synchronizations.find(synchronization_id)

    # for each synchronized pin
    synchronization.synchronized_pins.each do |synchronized_pin|
      # construct the message
      message = { "pin": synchronized_pin.pin.pin_number }

      # get the pin value based on whether we're getting the opposite value
      pin_value = (opposite == true) ? synchronized_pin.opposite_value : synchronized_pin.value

      # if this is a digital pin
      if self.digital_pins.include?(synchronized_pin.pin)
        # add to the message
        message.merge!({ "digital": pin_value })
      # else this is an analog pin
      else
        # add to the message
        message.merge!({ "servo": pin_value })
      end

      # broadcast the message
      self.broadcast_message(message)
    end
  end

  # broadcasts a message
  def broadcast_message(message)
    # exit if the data is malformed (pin is not a number)
    return false if message.keys.include?("pin") && (message["pin"].to_s != message["pin"].to_i.to_s)

    # exit if sleeptime is active
    return false if self.sleeptime_active?

    # if the i2c_address is present get the slave, otherwise return the parent
    input_device = (message["i2c_address"].present? ? self.devices.find_by(i2c_address: message["i2c_address"]) : self)

    # if we should broadcast to another device (which may be a slave)
    target_device = (input_device.broadcast_to_device.present? ? input_device.broadcast_to_device : self)

    # remove the action portion of the message if it's present
    message.delete("action") if message["action"].present?

    # transform the message
    message = input_device.transform_input_message(message)

    # constrain the message
    message = target_device.constrain_output_message(message)

    # change the i2c_address to the target_device's i2c_address
    message["i2c_address"] = target_device.i2c_address if target_device.i2c_address.present?

    # remove the i2c_address if it's blank
    message.delete("i2c_address") if message["i2c_address"].blank?

    # if this is a shutdown command
    if message['command'].present? && message['command'] == 'shutdown'
      # don't broadcast to target
      target_device = self
    # if this is a start video command
    elsif message['command'].present? && message['command'] == 'start_video'
      # add the video url
      message['video_url'] = self.video_from_devices_url
    # if this is a start audio command
    elsif message['command'].present? && message['command'] == 'start_rpi_microphone'
      # add the audio url
      message['audio_input_url'] = target_device.audio_input_url
      # don't broadcast to target
      target_device = self
    # if this is a stop audio command
    elsif message['command'].present? && message['command'] == 'stop_rpi_microphone'
      # don't broadcast to target
      target_device = self
    # if this is a start rpi speakers command
    elsif message['command'].present? && message['command'] == 'start_rpi_speakers'
      # if this message should be sent to the target device (when start_rpi_microphone occurs on sending device)
      if (message['send_to_target_device'] == true)
        message['audio_output_url'] = target_device.audio_output_url
      # else command is from the webpage and intended for self
      else
        # add the url
        message['audio_output_url'] = self.audio_output_url
        # don't broadcast to target
        target_device = self
      end
    # if this is a stop rpi speakers command
    elsif message['command'].present? && message['command'] == 'stop_rpi_speakers'
      # if this message should not be sent to the target device (when stop_rpi_microphone occurs on sending device)
      if (message['send_to_target_device'] != true)
        # don't broadcast to target
        target_device = self
      end
    end

    # broadcast to the target device's master (since we can't broadcast directly to a slave)
    DevicesChannel.broadcast_to(
      target_device.master_device.id,
      message.merge({ time: (Time.now.to_f * 1000).to_i })
    )
  end

  private

    # validate the slug
    def validate_slug
      # blank slugs are fine
      return true if self.slug.blank?

      # parameterize the slug
      self.slug = self.slug.parameterize

      # if the slug is a reserved word
      if %w(new create edit update).include?(self.slug)
        self.errors.add(:base, "Custom URL is invalid.")
      end

      # if the slug contains no letters
      if !self.slug.match(/[a-zA-Z]/).present?
        self.errors.add(:base, "Custom URL must contain letters.")
      end

      # if the slug is taken
      if Device.where(slug: self.slug).where.not(id: self.id).present?
        self.errors.add(:base, "Custom URL has already been taken.")
      end
    end

end
