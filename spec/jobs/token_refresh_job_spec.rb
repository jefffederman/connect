require "rails_helper"

describe TokenRefreshJob do
  it "updates the users refresh token" do
    user = double(User)
    allow(user).to receive :fresh_access_token

    TokenRefreshJob.perform_now(user)

    expect(user).to have_received :fresh_access_token
  end
end
