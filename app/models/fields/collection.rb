module Fields
  # Wraps values from Namely profile fields in an object able to convert to
  # useful formats.
  #
  # See value classes like {StringValue} for examples.
  class Collection
    def initialize(namely_connection)
      @namely_connection = namely_connection
    end

    def export(field_name, from:)
      value = from[field_name]
      field = find_field(field_name)
      if value && field
        factory_for(field.type).new(value)
      end
    end

    private

    def find_field(field_name)
      fields.detect { |field| field.name == field_name }
    end

    def factory_for(type)
      case type
      when "referencehistory"
        RecordValue
      when "date"
        DateValue
      when "address"
        AddressValue
      else
        StringValue
      end
    end

    def fields
      @fields ||= @namely_connection.fields.all
    end
  end
end
