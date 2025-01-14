ENV["RAILS_ENV"] = "test"
ENV["SHOW_FEATURE"] = "true"
ENV["NET_SUITE_CUSTOM_FIELDS_ENABLED"] = "true"

require File.expand_path("../../config/environment", __FILE__)

require "capybara/email/rspec"
require "rspec/rails"
require "shoulda/matchers"

Dir[Rails.root.join("spec/support/**/*.rb")].each { |file| require file }

module Features
  # Extend this module in spec/support/features/*.rb
  include Formulaic::Dsl
  include TranslationHelpers
end

RSpec.configure do |config|
  config.include Features, type: :feature
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false
  config.before :each, :js, type: :feature do |example|
    page.driver.block_unknown_urls
  end
end

ActiveRecord::Migration.maintain_test_schema!
Capybara.javascript_driver = :webkit
