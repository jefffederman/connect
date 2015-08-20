class Installation < ActiveRecord::Base
  has_many :users, dependent: :destroy
  has_one(
    :greenhouse_connection,
    class_name: "Greenhouse::Connection",
    dependent: :destroy
  )
  has_one(
    :icims_connection,
    class_name: "Icims::Connection",
    dependent: :destroy
  )
  has_one(
    :jobvite_connection,
    class_name: "Jobvite::Connection",
    dependent: :destroy
  )
  has_one(
    :net_suite_connection,
    class_name: "NetSuite::Connection",
    dependent: :destroy
  )

  validates :subdomain, presence: true, uniqueness: true

  def self.ready_to_sync_with(integration)
    association = "#{integration}_connection"
    joins(association.to_sym).
      where(association.pluralize => { found_namely_field: true })
  end

  def jobvite_connection
    super || Jobvite::Connection.create!(installation: self)
  end

  def icims_connection
    super || Icims::Connection.create!(installation: self)
  end

  def greenhouse_connection
    super || Greenhouse::Connection.create!(installation: self)
  end

  def net_suite_connection
    super || NetSuite::Connection.create!(installation: self)
  end

  def send_connection_notification(*arguments)
    users.each do |user|
      user.send_connection_notification(*arguments)
    end
  end

  def namely_connection
    owner.namely_connection
  end

  def namely_profiles
    owner.namely_profiles
  end

  private

  def owner
    users.first
  end
end
