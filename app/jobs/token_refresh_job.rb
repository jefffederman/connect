class TokenRefreshJob < ActiveJob::Base
  def perform(user)
    user.fresh_access_token
  end
end
