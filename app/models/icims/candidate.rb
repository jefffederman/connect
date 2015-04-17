require "ostruct"

module Icims
  class Candidate < OpenStruct
    def initialize(namely_connection, attributes)
      super attributes.map { |k,v| [k.underscore, v] }.to_h
      @namely_connection = namely_connection
    end

    def start_date
      if has_start_date?
        Date.parse(startdate).iso8601
      end
    end

    def name
      [firstname, lastname].join(" ")
    end

    def contact_number
      phone_numbers["Home"] || phone_numbers["Work"] || phone_numbers["Mobile"]
    end

    def to_partial_path
      "icims_imports/candidate"
    end

    def home_address
      if icims_home_address
        {
          address1: icims_home_address["addressstreet1"],
          address2: icims_home_address["addressstreet2"],
          city: icims_home_address["addresscity"],
          country_id: icims_home_address["addresscountry"]["abbrev"],
          state_id: icims_home_address["addressstate"]["abbrev"],
          zip: icims_home_address["addresszip"],
        }
      end
    end

    def salary
      if icims_salary
        {
          currency: icims_salary[:currency],
          date: start_date,
          yearly_amount: icims_salary[:amount],
        }
      end
    end

    def job_title
      @job_title ||= NamelyJobTitle.new(
        namely_connection: namely_connection,
        job_title_name: jobtitle,
      ).job_title
    end

    private

    def phone_numbers
      @phone_numbers ||= phones.inject({}) do |hash, phone|
        hash[phone["phonetype"]["value"]] = phone["phonenumber"]
        hash
      end
    end

    def phones
      @phones || []
    end

    def has_start_date?
      startdate.present?
    end

    def icims_salary
      self[:salary]
    end

    def icims_home_address
      if self[:addresses]
        @icims_home_address ||=
          addresses.detect { |address|
          address["addresstype"]["value"] == "Home"}
      end
    end
  end
end
