module Fields
  # Converts string values from Namely into other formats.
  class StringValue
    def initialize(value)
      @value = value
    end

    def to_raw
      @value
    end

    def to_s
      @value.to_s
    end

    def to_date
      nil
    end

    def to_address
      nil
    end
  end
end
