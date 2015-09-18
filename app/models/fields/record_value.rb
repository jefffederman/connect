module Fields
  # Converts record values like job titles from Namely into useful formats.
  class RecordValue
    def initialize(value)
      @value = value
    end

    def to_raw
      @value
    end

    def to_s
      @value[non_id_key]
    end

    def to_date
      nil
    end

    def to_address
      nil
    end

    private

    def non_id_key
      @value.except("id").keys.first
    end
  end
end
