class NetSuite::Normalizer
  GENDER_MAP = {
    "Male" => "_male",
    "Female" => "_female",
    "Not specified" => "_omitted",
  }
  GENDER_MAP.default = "_omitted"

  delegate :field_mappings, to: :attribute_mapper
  delegate :mapping_direction, to: :attribute_mapper
  delegate :persisted?, to: :attribute_mapper

  def initialize(attribute_mapper:, configuration:)
    @attribute_mapper = attribute_mapper
    @configuration = configuration
  end

  def export(profile)
    attribute_mapper.export(profile).tap do |exported_profile|
      exported_profile["gender"] = map_gender(exported_profile["gender"])
      exported_profile["subsidiary"] = set_subsidiary_id
      convert_custom_fields(exported_profile)
    end
  end

  private

  def map_gender(value)
    GENDER_MAP[value]
  end

  def set_subsidiary_id
    { "internalId" => configuration.subsidiary_id }
  end

  def convert_custom_fields(profile)
    custom_keys = profile.keys.grep(/^custom:/)
    custom_field_values = custom_keys.map do |key|
      (_, internal_id, script_id) = key.split(":", 3)
      {
        "internalId" => internal_id,
        "scriptId" => script_id,
        "value" => profile.delete(key),
      }
    end
    profile["customFieldList"] = { "customField" => custom_field_values }
  end

  attr_reader :attribute_mapper, :configuration
end
