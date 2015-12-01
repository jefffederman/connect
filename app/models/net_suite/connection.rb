class NetSuite::Connection < ActiveRecord::Base
  belongs_to :attribute_mapper, dependent: :destroy
  belongs_to :installation
  has_many :sync_summaries, as: :connection

  validates :subsidiary_id, presence: true, allow_nil: true
  validates :matching_type, presence: true

  delegate :export, to: :normalizer

  enum matching_type: [ :email_matcher, :name_matcher ]

  after_initialize :set_defaults

  def lockable?
    true
  end

  def integration_id
    :net_suite
  end

  def allowed_parameters
    [:subsidiary_id, :matching_type]
  end

  def connected?
    instance_id.present? && authorization.present?
  end

  def enabled?
    ENV["CLOUD_ELEMENTS_ORGANIZATION_SECRET"].present?
  end

  def attribute_mapper?
    true
  end

  def configurable?
    false
  end

  def has_activity_feed?
    true
  end

  def attribute_mapper
    AttributeMapperFactory.new(attribute_mapper: super, connection: self).
      build_with_defaults { |mappings| map_defaults(mappings) }
  end

  def ready?
    subsidiary_id.present? || subsidiary_optional?
  end

  def required_namely_field
    :netsuite_id
  end

  def subsidiaries
    client.
      subsidiaries.
      map { |subsidiary| [subsidiary["name"], subsidiary["internalId"]] }
  end

  def sync
    update_attribute(:locked, true)
    perform_export(installation.namely_profiles)
  ensure
    update_attribute(:locked, false)
  end

  def retry(sync_summary)
    perform_export(sync_summary.failed_profiles)
  end

  def client
    NetSuite::Client.from_env.authorize(authorization)
  end

  private

  def perform_export(profiles)
    summary = SyncSummary.create(
      connection: self
    )
    NetSuite::Export.perform(
      summary_id: summary.id,
      normalizer: normalizer,
      namely_profiles: profiles,
      net_suite_connection: self,
    )
  end

  def subsidiary_optional?
    if subsidiary_required.nil?
      update!(subsidiary_required: subsidiaries.present?)
    end

    !subsidiary_required?
  end

  def normalizer
    @normalizer ||= NetSuite::Normalizer.new(
      attribute_mapper: attribute_mapper,
      configuration: self
    )
  end

  def map_defaults(mappings)
    map_standard_fields(mappings)
    map_remote_fields(mappings)
  end

  def map_remote_fields(mappings)
    mappable_fields.each do |profile_field|
      mappings.map! profile_field.id, name: profile_field.name
    end
  end

  def mappable_fields
    client.profile_fields.select do |profile_field|
      profile_field.type == "text"
    end
  end

  def map_standard_fields(mappings)
    mappings.map! "address", to: "home", name: "Address"
    mappings.map! "email", to: "email", name: "Email"
    mappings.map! "firstName", to: "first_name", name: "First name"
    mappings.map! "gender", to: "gender", name: "Gender"
    mappings.map! "isInactive", to: "user_status", name: "Inactive"
    mappings.map! "lastName", to: "last_name", name: "Last name"
    mappings.map! "middleName", to: "middle_name", name: "Middle name"
    mappings.map! "mobilePhone", to: "mobile_phone", name: "Mobile phone"
    mappings.map! "officePhone", to: "office_phone", name: "Office phone"
    mappings.map! "phone", to: "home_phone", name: "Phone"
    mappings.map! "title", to: "job_title", name: "Title"
    mappings.map! "hireDate", to: "start_date", name: "Hire Date"

    mappings.map!(
      "releaseDate",
      to: "departure_date",
      name: "Release Date"
    )
  end

  def set_defaults
    self.matching_type ||= "email_matcher"
  end
end
