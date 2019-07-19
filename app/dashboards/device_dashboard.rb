require "administrate/base_dashboard"

class DeviceDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    device: Field::BelongsTo,
    broadcast_to_device: Field::BelongsTo.with_options(class_name: "Device"),
    devices: Field::HasMany,
    pins: Field::HasMany,
    synchronizations: Field::HasMany,
    registrations: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    device_type: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    auth_token: Field::String,
    i2c_address: Field::String,
    broadcast_to_device_id: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :user,
    :name,
    :device_type,
    :created_at,
    :updated_at
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :user,
    :device,
    :broadcast_to_device,
    :devices,
    :pins,
    :synchronizations,
    :registrations,
    :id,
    :name,
    :device_type,
    :created_at,
    :updated_at,
    :auth_token,
    :i2c_address,
    :broadcast_to_device_id,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :user,
    :device,
    :broadcast_to_device,
    :devices,
    :pins,
    :synchronizations,
    :registrations,
    :name,
    :device_type,
    :auth_token,
    :i2c_address,
    :broadcast_to_device_id,
  ].freeze

  # Overwrite this method to customize how devices are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(device)
  #   "Device ##{device.id}"
  # end
end
