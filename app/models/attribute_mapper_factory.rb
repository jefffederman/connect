class AttributeMapperFactory
  def initialize(connection: , attribute_mapper:)
    @attribute_mapper = attribute_mapper
    @connection = connection
  end

  def build_with_defaults(&block)
    @attribute_mapper || assign_attribute_mapper(&block)
  end

  private

  def assign_attribute_mapper
    AttributeMapper.transaction do
      AttributeMapper.create!.tap do |attribute_mapper|
        @connection.update!(attribute_mapper: attribute_mapper)
        yield attribute_mapper.field_mappings
      end
    end
  end
end
