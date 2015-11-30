class NetSuite::Normalizer
  delegate :field_mappings, to: :attribute_mapper
  delegate :mapping_direction, to: :attribute_mapper
  delegate :persisted?, to: :attribute_mapper

  def initialize(attribute_mapper:, configuration:)
    @attribute_mapper = attribute_mapper
    @configuration = configuration
  end

  def export(profile)
    attributes = attribute_mapper.export(profile)
    Export.new(attributes, @configuration.subsidiary_id).to_hash
  end

  private

  class Export
    include ::NetSuite::Constants

    def initialize(attributes, subsidiary_id)
      @attributes = attributes
      @subsidiary_id = subsidiary_id
    end

    def to_hash
      with_null_field_list(
        mapped_attributes.
          merge(address_attributes).
          merge(string_attributes).
          merge(custom_fields_attributes)
      )
    end

    private

    def mapped_attributes
      @mapped_attributes ||= {
        "gender" => gender,
        "isInactive" => user_status,
        "subsidiary" => subsidiary,
        "releaseDate" => release_date,
        "hireDate" => hire_date,
      }
    end

    def string_attributes
      string_keys.each_with_object({}) do |(key, value), result|
        result[key] = value.to_s
      end
    end

    def string_keys
      @attributes.
        except(*mapped_attributes.keys).
        except(*custom_keys(@attributes)).
        except("address")
    end

    def gender
      GENDER_MAP[@attributes["gender"].to_s]
    end

    def country(namely_value)
      COUNTRY_MAP[namely_value]
    end

    def user_status
      @attributes["isInactive"].to_s == "inactive"
    end

    def release_date
      date = @attributes.fetch("releaseDate", Fields::NullValue.new).to_date

      if date.present?
        date.to_datetime.to_i * 1.second.in_milliseconds
      end
    end

    def hire_date
      date = @attributes.fetch("hireDate", Fields::NullValue.new).to_date

      if date.present?
        date.to_datetime.iso8601
      end
    end

    def subsidiary
      { "internalId" => @subsidiary_id }
    end

    def custom_keys(attributes)
      attributes.keys.grep(/^custom:/)
    end

    def custom_fields_attributes
      if ENV["NET_SUITE_CUSTOM_FIELDS_ENABLED"] == "true"
        { "customFieldList" => custom_fields }
      else
        {}
      end
    end

    def custom_fields
      custom_field_values = custom_keys(@attributes).map do |key|
        (_, internal_id, script_id) = key.split(":", 3)
        {
          "internalId" => internal_id,
          "scriptId" => script_id,
          "value" => @attributes[key].to_s,
        }
      end
      { "customField" => custom_field_values }
    end

    def address_attributes
      if address.present?
        {
          "addressbookList" => {
            "addressbook" => addresses,
            "replaceAll" => true
          }
        }
      else
        {}
      end
    end

    def addresses
      [
        {
          "defaultShipping" => true,
          "addressbookAddress" => {
            "zip" => address.zip,
            "country" => {
              "value" => country(address.country)
            },
            "addr1" => address.street1,
            "addr2" => address.street2,
            "addr3" => "",
            "city" => address.city,
            "addressee" => addressee,
            "attention" => "",
            "state" => address.state,
          }
        }
      ]
    end

    def addressee
      [
        @attributes["firstName"],
        @attributes["lastName"],
      ].join(" ")
    end

    def address
      if @attributes["address"]
        @attributes["address"].to_address
      end
    end

    def with_null_field_list(fields)
      fields.tap do |mapped_fields|
        mapped_fields["nullFieldList"] = mapped_fields.select do |_, value|
          value.nil?
        end.keys
      end.compact
    end
  end

  private_constant :Export
  attr_reader :attribute_mapper
end
