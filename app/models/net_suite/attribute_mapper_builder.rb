module NetSuite
  class AttributeMapperBuilder
    attr_accessor :attribute_mapper

    def initialize(user:)
      @attribute_mapper = AttributeMapper.new(
        mapping_direction: "export",
        user: user
      )
    end

    def build
      attribute_mapper.save
    end
  end
end
