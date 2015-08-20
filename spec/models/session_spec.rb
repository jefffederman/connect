require "rails_helper"

describe Session do
  describe "delegations" do
    subject do
      described_class.new(
        double("authenticator"),
        code: "an-auth-code",
        subdomain: "a-subdomain",
      )
    end

    it { should delegate_method(:user_id).to(:user).as(:id) }
  end

  describe "#user" do
    context "for a new User" do
      it "creates and returns a User" do
        expiry_time = Time.current + expiry_time_in_seconds.seconds
        authenticator = authenticator_double(
          namely_user_id: "a-namely-user",
          access_token: "my-access-token",
          refresh_token: "my-refresh-token",
          expires_in: expiry_time_in_seconds,
        )
        session = described_class.new(
          authenticator,
          code: "my-code",
          subdomain: "my-subdomain",
        )

        user = session.user
        installation = user.installation

        expect(user.namely_user_id).to eq "a-namely-user"
        expect(user.subdomain).to eq "my-subdomain"
        expect(user.access_token).to eq "my-access-token"
        expect(user.access_token_expiry).to be_within(1.second).of(expiry_time)
        expect(user.refresh_token).to eq "my-refresh-token"
        expect(user.email).to eq "corgilover1965@example.com"
        expect(user.first_name).to eq "Eugene"
        expect(user.last_name).to eq "Belford"
        expect(user).to be_persisted
        expect(installation.subdomain).to eq "my-subdomain"
        expect(installation).to be_persisted
        expect(authenticator).to have_received(:retrieve_tokens).with("my-code")
        expect(authenticator).to have_received(:current_user).with("my-access-token")
      end
    end

    context "for a returning User" do
      it "updates and returns a User" do
        expiry_time = Time.current + expiry_time_in_seconds.seconds
        subdomain = "my-subdomain"
        installation = create(:installation, subdomain: subdomain)
        existing_user = create(
          :user,
          namely_user_id: "a-namely-user",
          subdomain: subdomain,
          access_token: "old-access-token",
          refresh_token: "old-refresh-token",
          installation: installation,
        )
        authenticator = authenticator_double(
          namely_user_id: existing_user.namely_user_id,
          access_token: "new-access-token",
          expires_in: expiry_time_in_seconds,
          refresh_token: "new-refresh-token",
        )
        session = described_class.new(
          authenticator,
          code: "my-code",
          subdomain: subdomain,
        )

        user = session.user

        existing_user.reload
        expect(user).to eq existing_user
        expect(existing_user.access_token).to eq "new-access-token"
        expect(user.access_token_expiry).to be_within(1.second).of(expiry_time)
        expect(existing_user.refresh_token).to eq "new-refresh-token"
      end
    end
  end

  def authenticator_double(
        namely_user_id:,
        access_token:,
        refresh_token:,
        expires_in:
      )
    namely_profile = double(
      "Profile",
      id: namely_user_id,
      email: "corgilover1965@example.com",
      first_name: "Eugene",
      last_name: "Belford",
    )
    double(
      "Namely::Authenticator",
      retrieve_tokens: {
        "access_token" => access_token,
        "expires_in" => expires_in,
        "refresh_token" => refresh_token,
        "token_type" => "bearer",
      },
      current_user: namely_profile,
    )
  end

  def expiry_time_in_seconds
    899
  end
end
