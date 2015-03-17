require "ostruct"

module Jobvite
  class Candidate < OpenStruct
    def initialize(attributes)
      super attributes.map { |k,v| [k.underscore, v] }.to_h
    end

    def start_date
      if has_start_date?
        Date.strptime(start_date_unix_timestamp.to_s, "%s").iso8601
      end
    end

    def gender
      application["gender"]
    end

    def name
      "#{self["first_name"]} #{self["last_name"]}"
    end

    def contact_number
      home_phone || work_phone || cell_phone
    end

    private

    def has_start_date?
      application["startDate"].present?
    end

    def start_date_unix_timestamp
      application["startDate"] / 1000
    end
  end
end
