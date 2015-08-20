module Greenhouse
  class Normalizer
    # Initializes an attribute mapper using Namely Fields
    def initialize(namely_fields)
      @namely_fields = namely_fields
    end

    def call(payload)
      custom_fields(candidate(payload)).
        merge(custom_fields(offer(payload))).
        merge(custom_fields(job(payload))).
        merge(basic_fields(payload)).
        select { |_, value| value.present? }
    end

    def namely_identifier_field
      :greenhouse_id
    end

    private

    # TODO: refactor this method
    def basic_fields(payload)
      {
        first_name: candidate(payload).fetch("first_name"),
        last_name: candidate(payload).fetch("last_name"),
        email: email_for(candidate(payload), "work"),
        personal_email: email_for(candidate(payload), "personal"),
        user_status: "active",
        start_date: offer(payload).fetch("starts_at"),
        home: home_address_for(candidate(payload)),
        namely_identifier_field => identifier(application(payload)).to_s,
        salary: salary_field(payload),
      }
    end

    def custom_fields(payload)
      p = payload.fetch("custom_fields", {})
      if p.present?
        Greenhouse::CustomFields.match(
          namely_fields: @namely_fields,
          payload: p
        )
      else
        {}
      end
    end

    def candidate(payload)
      application(payload).fetch("candidate")
    end

    def identifier(payload)
      payload.fetch("id")
    end

    def application(payload)
      payload.fetch("application")
    end

    def offer(payload)
      application(payload).fetch("offer", { "starts_at" => "" })
    end

    def job(payload)
      application(payload).fetch("job")
    end

    def salary_field(payload)
      custom_fields = offer(payload).fetch("custom_fields", {})
      salary = custom_fields.fetch("salary", nil)
      if salary.present?
        if salary.fetch("type") == "currency"
          {
            yearly_amount: salary.fetch("value").fetch("amount"),
            currency_type: salary.fetch("value").fetch("unit"),
            date: offer(payload).fetch("starts_at")
          }
        else
          {
            yearly_amount: salary.fetch("value").to_i,
            currency_type: "USD",
            date: offer(payload).fetch("starts_at")
          }
        end
      else
        {}
      end
    end

    def email_for(payload, type)
      addresses = payload.fetch("email_addresses", []) || []
      email_address = addresses.find do |email_address|
        email_address.fetch("type") == type
      end
      if email_address.present?
        email_address.fetch("value")
      else
        nil
      end
    end


    def home_address_for(candidate)
      home_address = candidate.fetch("addresses", [])
      if home_address
        home_address = home_address.find do |address|
          address.fetch("type") == "home"
        end || {}
        { address1: home_address.fetch("value", "") }
      else
        nil
      end
    end
  end
end
