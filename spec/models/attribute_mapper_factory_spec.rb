require "rails_helper"

describe AttributeMapperFactory do
  describe "#build_with_defaults" do
    context "with an existing attribute mapper" do
      it "returns the attribute mapper" do
        attribute_mapper = create(:attribute_mapper)
        connection = create(
          :net_suite_connection,
          attribute_mapper: attribute_mapper
        )
        factory = AttributeMapperFactory.new(
          attribute_mapper: attribute_mapper,
          connection: connection,
        )

        result = factory.build_with_defaults { |_| }

        expect(result).to eq(attribute_mapper)
        expect(connection.reload.attribute_mapper.id).to eq(attribute_mapper.id)
      end
    end

    context "without an existing attribute mapper" do
      it "saves a new attribute mapper with the given defaults" do
        connection = create(:net_suite_connection)
        factory = AttributeMapperFactory.new(
          attribute_mapper: nil,
          connection: connection
        )

        result = factory.build_with_defaults do |mappings|
          mappings.map!("firstName", to: "first_name", name: "First name")
        end

        expect(connection.reload.attribute_mapper_id).to eq(result.id)
        expect(mapped_fields_for(result)).to eq([%w(firstName first_name)])
      end
    end

    context "when creating the mapper fails" do
      it "doesn't commit the mapper" do
        connection = create(:net_suite_connection)
        factory = AttributeMapperFactory.new(
          attribute_mapper: nil,
          connection: connection
        )
        exception = StandardError.new("failure")

        expect { build_defaults_and_raise(factory, exception) }.
          to raise_error(exception)
        expect(connection.reload.attribute_mapper_id).to be_nil
      end
    end
  end

  def build_defaults_and_raise(factory, exception)
    factory.build_with_defaults do |mappings|
      mappings.map!("firstName", to: "first_name", name: "First name")
      raise exception
    end
  end

  def mapped_fields_for(attribute_mapper)
    attribute_mapper.field_mappings.map do |field_mapping|
      [field_mapping.integration_field_id, field_mapping.namely_field_name]
    end
  end
end
