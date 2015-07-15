module Icims
  class Connection < ActiveRecord::Base
    belongs_to :user
    validates :user_id, presence: true
    validates :api_key, uniqueness: true
    before_create :set_api_key

    def self.for_api_key(api_key:, customer_id:)
      self.find_by(api_key: api_key.to_s, customer_id: customer_id) ||
        InvalidConnection.new
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

    def disconnect
      update(
        customer_id: nil,
        key: nil,
        username: nil,
      )
    end

    def required_namely_field
      AttributeMapper.new.namely_identifier_field.to_s
    end

    def set_api_key
      self.api_key = SecureRandom.hex(20)
    end

    def build_candidate_importer(*import_params)
      CandidateImporter.new(*import_params)
    end

    class InvalidConnection
      def build_candidate_importer(*import_params)
        InvalidCandidateImporter.new(*import_params)
      end
    end
    private_constant :InvalidConnection
  end
end
