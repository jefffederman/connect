class NetSuite::AttributeMapperBuilder
  attr_accessor :attribute_mapper

  delegate :field_mappings, to: :attribute_mapper

  def initialize(user:)
    @attribute_mapper = AttributeMapper.new(
      mapping_direction: "export",
      user: user
    )
  end

  def build
    attribute_mapper.save
    build_field_mappings
  end

  def default_field_mapping
    {
      "email" => "email",
      "first_name" => "firstName",
      "gender" => "gender",
      "last_name" => "lastName",
      "home_phone" => "phone",
    }
  end

  private

  def build_field_mappings
    default_field_mapping.each_pair do |namely_field, integration_field|
      attribute_mapper.field_mappings << FieldMapping.new(
        integration_field_name: integration_field.to_s,
        namely_field_name: namely_field
      )
    end
  end
end
