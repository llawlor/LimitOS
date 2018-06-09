require "administrate/base_dashboard"

class RegistrationDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    device: Field::BelongsTo,
    id: Field::Number,
    auth_token: Field::String,
    expires_at: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :device,
    :id,
    :auth_token,
    :expires_at,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :device,
    :id,
    :auth_token,
    :expires_at,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :device,
    :auth_token,
    :expires_at,
  ].freeze

  # Overwrite this method to customize how registrations are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(registration)
  #   "Registration ##{registration.id}"
  # end
end
