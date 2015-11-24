module Icims
  class Connection < ActiveRecord::Base
    belongs_to :installation
    validates :api_key, uniqueness: true
    before_create :set_api_key

    def lockable?
      false
    end

    def integration_id
      :icims
    end

    def connected?
      username.present? && key.present? && customer_id.present?
    end

    def enabled?
      true
    end

    def ready?
      true
    end

    def api_url
      "https://api.icims.com/customers/#{customer_id}"
    end

    def attribute_mapper?
      false
    end

    def configurable?
      false
    end

    def has_activity_feed?
      false
    end

    def required_namely_field
      Normalizer.new.namely_identifier_field.to_s
    end

    def set_api_key
      self.api_key = SecureRandom.hex(20)
    end
  end
end
