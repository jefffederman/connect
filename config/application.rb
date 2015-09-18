require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Connect
  class Application < Rails::Application
    require_relative "../lib/exceptions"

    config.i18n.enforce_available_locales = true
    config.active_record.default_timezone = :utc

    config.generators do |generate|
      generate.helper false
      generate.javascript_engine false
      generate.request_specs false
      generate.routing_specs false
      generate.stylesheets false
      generate.test_framework :rspec
      generate.view_specs false
    end

    config.action_controller.action_on_unpermitted_parameters = :raise
    config.active_job.queue_adapter = :delayed_job
    config.namely_authentication_domain = ENV.fetch("NAMELY_DOMAIN", "%{subdomain}.namely.com")
    config.namely_authentication_protocol = ENV.fetch("NAMELY_PROTOCOL", "https")
    config.namely_api_redirect_uri = "#{ENV.fetch("HOST")}/session/oauth_callback"
    config.namely_api_domain = ENV.fetch("NAMELY_DOMAIN", "%{subdomain}.namely.com")
    config.namely_api_protocol = ENV.fetch("NAMELY_PROTOCOL", "https")
    config.namely_client_id = ENV.fetch("NAMELY_CLIENT_ID")
    config.namely_client_secret = ENV.fetch("NAMELY_CLIENT_SECRET")
  end
end
