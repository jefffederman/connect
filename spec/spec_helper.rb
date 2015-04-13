require "webmock/rspec"
require 'delegate'

require 'timecop'
require 'active_support/time'

require_relative '../app/services/users/user_with_full_name'
require_relative '../app/services/users/access_token_freshener'
require_relative '../app/services/users/token_expiry'

require_relative '../app/services/jobvites/connection_updater'

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
