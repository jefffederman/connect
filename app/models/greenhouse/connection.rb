module Greenhouse
  class Connection < ActiveRecord::Base
    belongs_to :attribute_mapper, dependent: :destroy
    belongs_to :installation
    validates :secret_key, uniqueness: true
    before_create :set_secret_key

    def connected?
      name.present?
    end

    def enabled?
      true
    end

    def ready?
      true
    end

    def attribute_mapper?
      true
    end

    def attribute_mapper
      AttributeMapperFactory.new(attribute_mapper: super, connection: self).
        build_with_defaults do |mappings|
          mappings.map! "first_name", to: "first_name", name: "First name"
          mappings.map! "middle_name", to: "middle_name", name: "Middle name"
          mappings.map! "last_name", to: "last_name", name: "Last name"
          mappings.map! "work_email", to: "email", name: "Work email"
          mappings.map!(
            "personal_email",
            to: "personal_email",
            name: "Personal email"
          )
          mappings.map! "starts_at", to: "start_date", name: "Starts at"
        end
    end

    def configurable?
      false
    end

    def has_activity_feed?
      false
    end

    def required_namely_field
      "greenhouse_id"
    end

    def integration_id
      :greenhouse
    end

    def set_secret_key
      self.secret_key = SecureRandom.hex(20)
    end
  end
end
