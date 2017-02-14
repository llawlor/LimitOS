require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LimitOS
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # don't add assets and helpers when using 'rails generate'
    config.generators.assets = false
    config.generators.helper = false

    # allow requests from any origin
    config.action_cable.disable_request_forgery_protection = true
  end
end
