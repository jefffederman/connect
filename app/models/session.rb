class Session
  delegate :id, to: :user, prefix: true

  def initialize(authenticator, code:, subdomain:, user_model: User)
    @authenticator = authenticator
    @code = code
    @subdomain = subdomain
    @user_model = user_model
  end

  def user
    @user ||= user_model.find_or_initialize_by(
      installation: installation,
      namely_user_id: namely_user.id,
      subdomain: subdomain,
    ).tap do |user|
      user_update_credentials(user)
    end
  end

  private

  attr_reader :authenticator, :code, :subdomain, :user_model

  def user_update_credentials(user)
      user.update!(
        access_token: access_token,
        access_token_expiry: Users::TokenExpiry.for(access_token_expiry),
        refresh_token: refresh_token,
        email: namely_user.email,
        first_name: namely_user.first_name,
        last_name: namely_user.last_name,
      )
  end

  def namely_user
    @namely_user ||= authenticator.current_user(access_token)
  end

  def access_token
    tokens.fetch("access_token")
  end

  def access_token_expiry
    tokens.fetch("expires_in")
  end

  def refresh_token
    tokens.fetch("refresh_token")
  end

  def installation
    @installation ||= Installation.find_or_initialize_by(
      subdomain: subdomain
    )
  end

  def tokens
    @tokens ||= authenticator.retrieve_tokens(code)
  end

end
