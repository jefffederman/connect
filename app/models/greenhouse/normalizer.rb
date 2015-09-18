module Greenhouse
  class Normalizer
    NAMELY_IDENTIFIER_FIELD = :greenhouse_id

    def initialize(attribute_mapper:, namely_fields:)
      @attribute_mapper = attribute_mapper
      @namely_fields = namely_fields
    end

    def call(data)
      candidate = Payload.new(data, namely_fields: @namely_fields).to_hash
      imported = @attribute_mapper.import(candidate)
      imported.merge(
        candidate.slice(NAMELY_IDENTIFIER_FIELD, :salary, :home, :user_status)
      )
    end

    def namely_identifier_field
      NAMELY_IDENTIFIER_FIELD
    end

    private

    class Payload
      def initialize(data, namely_fields:)
        @data = data
        @namely_fields = namely_fields
      end

      def to_hash
        custom_fields(candidate).
          merge(custom_fields(offer)).
          merge(custom_fields(job)).
          merge(basic_fields).
          select { |_, value| value.present? }
      end

      def basic_fields
        {
          first_name: candidate.fetch("first_name"),
          last_name: candidate.fetch("last_name"),
          work_email: email_for("work"),
          personal_email: email_for("personal"),
          user_status: "active",
          starts_at: offer.fetch("starts_at"),
          home: home_address,
          NAMELY_IDENTIFIER_FIELD => identifier.to_s,
          salary: salary_field,
        }
      end

      def custom_fields(payload)
        fields = payload.fetch("custom_fields", {})
        if fields.present?
          Greenhouse::CustomFields.match(
            namely_fields: @namely_fields,
            payload: fields
          )
        else
          {}
        end
      end

      def candidate
        application.fetch("candidate")
      end

      def identifier
        application.fetch("id")
      end

      def application
        @data.fetch("application")
      end

      def offer
        application.fetch("offer") { { "starts_at" => "" } }
      end

      def job
        application.fetch("job")
      end

      def salary_field
        custom_fields = offer.fetch("custom_fields", {})
        salary = custom_fields.fetch("salary", {})
        case salary["type"]
        when "currency"
          {
            yearly_amount: salary.fetch("value").fetch("amount"),
            currency_type: salary.fetch("value").fetch("unit"),
            date: offer.fetch("starts_at")
          }
        when nil
          {}
        else
          {
            yearly_amount: salary.fetch("value").to_i,
            currency_type: "USD",
            date: offer.fetch("starts_at")
          }
        end
      end

      def email_for(type)
        email_address =
          email_addresses.detect { |address| address.fetch("type") == type }

        if email_address.present?
          email_address.fetch("value")
        else
          nil
        end
      end

      def email_addresses
        candidate["email_addresses"] || []
      end

      def home_address
        home_address = candidate.fetch("addresses", [])
        if home_address
          home_address = home_address.detect do |address|
            address.fetch("type") == "home"
          end || {}
          { address1: home_address.fetch("value", "") }
        else
          nil
        end
      end
    end

    private_constant :Payload
    private_constant :NAMELY_IDENTIFIER_FIELD
  end
end
