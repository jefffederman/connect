require "webmock/rspec"
require 'delegate'

require 'timecop'
require 'active_support/time'

require_relative '../app/connect/users/user_with_full_name'
require_relative '../app/connect/users/access_token_freshner'
require_relative '../app/connect/users/token_expiry'

# http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end

  config.order = :random
end

WebMock.disable_net_connect!(allow_localhost: true)
