module Greenhouse
  class Connection < ActiveRecord::Base
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
