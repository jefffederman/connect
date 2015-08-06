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
      build_with_defaults(
        "email" => "email",
        "firstName" => "first_name",
        "gender" => "gender",
        "phone" => "home_phone",
        "title" => "job_title",
        "lastName" => "last_name",
      )
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
end
