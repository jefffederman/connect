module Jobvite
  class Normalizer
    def initialize(attribute_mapper:)
      @attribute_mapper = attribute_mapper
    end

    def call(jobvite_candidate)
      @attribute_mapper.import(
        first_name: jobvite_candidate.first_name,
        last_name: jobvite_candidate.last_name,
        email: jobvite_candidate.email,
        personal_email: jobvite_candidate.email,
        user_status: "active",
        start_date: jobvite_candidate.start_date,
        gender: namely_gender(jobvite_candidate.gender),
      ).merge(
        namely_identifier_field => identifier(jobvite_candidate)
      )
    end

    def namely_identifier_field
      :jobvite_id
    end

    def identifier(jobvite_candidate)
      jobvite_candidate.e_id
    end

    def readable_name(jobvite_candidate)
      [
        jobvite_candidate.first_name,
        jobvite_candidate.last_name,
        "(#{identifier(jobvite_candidate)})",
      ].join(" ")
    end

    private

    def namely_gender(jobvite_gender)
      ["Male", "Female"].detect { |gender| gender == jobvite_gender }
    end
  end
end
