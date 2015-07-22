class NetSuite::Connection < ActiveRecord::Base
  belongs_to :attribute_mapper, dependent: :destroy
  belongs_to :user, dependent: :destroy

  validates :subsidiary_id, presence: true, allow_nil: true

  after_create :build_attribute_mapper

  delegate :export, to: :attribute_mapper
  delegate :post_handle, to: :attribute_mapper

  def attribute_mapper
    @attribute_mapper ||= NetSuite::AttributeMapper.new(
      attribute_mapper: super,
      configuration: self
    )
  end

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
      configuration: self,
      namely_profiles: user.namely_profiles.all,
      net_suite: client
    ).perform
  end

  def client
    NetSuite::Client.from_env(user).authorize(authorization)
  end

  def disconnect
    update!(instance_id: nil, authorization: nil)
  end

  private

  def build_attribute_mapper
    builder = NetSuite::AttributeMapperBuilder.new(user: user)
    self.attribute_mapper = builder.build
    save
  end
end
