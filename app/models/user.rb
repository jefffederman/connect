class User < ActiveRecord::Base
  belongs_to :installation
  delegate :greenhouse_connection, to: :installation
  delegate :icims_connection, to: :installation
  delegate :jobvite_connection, to: :installation
  delegate :net_suite_connection, to: :installation

  def full_name
    Users::UserWithFullName.new(self).full_name
  end

  def namely_profiles
    namely_connection.profiles.all.map do |profile|
      Profile.new(profile, fields: Fields::Collection.new(namely_connection))
    end
  end

  def namely_fields_by_label
    namely_fields.
      all.
      select { |field| AttributeMapper::SUPPORTED_TYPES.include?(field.type) }.
      sort_by { |field| field.label.downcase }.
      map { |field| [field.label, field.name] }
  end

  def namely_fields
    namely_connection.fields
  end

  def namely_connection
    Namely::Connection.new(
      access_token: fresh_access_token,
      subdomain: subdomain,
    )
  end

  def fresh_access_token
    Users::AccessTokenFreshener.fresh_access_token(self)
  end

  def save_token_info(access_token, access_token_expires_in)
    self.access_token = access_token
    self.access_token_expiry = Users::TokenExpiry.for(access_token_expires_in)
    save
  end
end
