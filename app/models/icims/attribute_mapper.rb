module Icims
  class AttributeMapper
    def call(icims_candidate)
      {
        first_name: icims_candidate.firstname,
        last_name: icims_candidate.lastname,
        email: icims_candidate.email,
        user_status: "active",
        start_date: icims_candidate.start_date,
        gender: namely_gender(icims_candidate.gender),
        salary: icims_candidate.salary,
        home: icims_candidate.home_address,
        namely_identifier_field => identifier(icims_candidate),
      }.select { |_, value| value.present? }
    end

    def namely_identifier_field
      :icims_id
    end

    def identifier(candidate)
      candidate.id
    end

    def readable_name(candidate)
      "#{candidate.name} (#{candidate.id})"
    end

    private

    def namely_gender(icims_gender)
      ["Male", "Female"].detect { |gender| gender == icims_gender }
    end
  end
end
