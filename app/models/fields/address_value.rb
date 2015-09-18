module Fields
  # Converts Namely address fields to useful formats.
  class AddressValue
    def initialize(value)
      @value = value
    end

    def to_raw
      @value
    end

    def to_s
      to_address.to_s
    end

    def to_date
      nil
    end

    def to_address
      address = Address.new(@value)
      if address.valid?
        address
      end
    end

    class Address
      def initialize(value)
        @value = value
      end

      def valid?
        street1.present? &&
          city.present? &&
          state.present? &&
          zip.present? &&
          country.present?
      end

      def street1
        @value["address1"]
      end

      def street2
        @value["address2"]
      end

      def city
        @value["city"]
      end

      def state
        @value["state_id"]
      end

      def zip
        @value["zip"]
      end

      def country
        @value["country_id"]
      end

      def to_s
        [
          street1,
          street2,
          "#{city}, #{state} #{zip}",
          country
        ].reject(&:blank?).join("\n")
      end
    end

    private_constant :Address
  end
end
