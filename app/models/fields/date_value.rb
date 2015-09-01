module Fields
  # Converts date values from Namely.
  class DateValue
    DATE_FORMAT = "%m/%d/%Y"

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
      DateTime.strptime(@value, DATE_FORMAT).to_date
    end

    private_constant :DATE_FORMAT
  end
end