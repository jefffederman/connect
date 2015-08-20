class NetSuite::Connection < ActiveRecord::Base
  belongs_to :attribute_mapper, dependent: :destroy
  belongs_to :installation

  validates :subsidiary_id, presence: true, allow_nil: true

  delegate :export, to: :normalizer

  def integration_id
    :net_suite
  end

  def allowed_parameters
    [:subsidiary_id]
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

  def attribute_mapper
    AttributeMapperFactory.new(attribute_mapper: super, connection: self).
      build_with_defaults { |mappings| map_defaults(mappings) }
  end

  def ready?
    subsidiary_id.present?
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
    NetSuite::Export.new(
      normalizer: normalizer,
      namely_profiles: installation.namely_profiles,
      net_suite: client
    ).perform
  end

  def client
    NetSuite::Client.from_env.authorize(authorization)
  end

  private

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
    mappings.map! "email", to: "email", name: "Email"
    mappings.map! "firstName", to: "first_name", name: "First name"
    mappings.map! "gender", to: "gender", name: "Gender"
    mappings.map! "lastName", to: "last_name", name: "Last name"
    mappings.map! "phone", to: "home_phone", name: "Phone"
    mappings.map! "title", to: "job_title", name: "Title"
  end
end
