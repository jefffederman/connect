module Jobvite
  class Connection < ActiveRecord::Base
    belongs_to :attribute_mapper, dependent: :destroy
    belongs_to :installation

    validates :hired_workflow_state, presence: true

    def integration_id
      :jobvite
    end

    def connected?
      api_key.present? && secret.present?
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

    def configurable?
      false
    end

    def has_activity_feed?
      false
    end

    def attribute_mapper
      AttributeMapperFactory.new(attribute_mapper: super, connection: self).
        build_with_defaults do |mappings|
          mappings.map! "first_name", to: "first_name", name: "First name"
          mappings.map! "last_name", to: "last_name", name: "Last name"
          mappings.map! "email", to: "email", name: "Email"
          mappings.map! "personal_email", to: "personal_email", name: "Email"
          mappings.map! "start_date", to: "start_date", name: "Start date"
          mappings.map! "gender", to: "gender", name: "Gender"
        end
    end

    def required_namely_field
      normalizer.namely_identifier_field.to_s
    end

    def sync
      import_results.map do |result|
        Result.new(**result)
      end
    end

    private

    def import_results
      Importer.new(
        client: Jobvite::Client.new(self),
        connection: self,
        namely_connection: namely_connection,
        namely_importer: namely_importer,
      ).import
    end

    def namely_importer
      NamelyImporter.new(
        normalizer: normalizer,
        namely_connection: namely_connection,
      )
    end

    def namely_connection
      installation.namely_connection
    end

    def normalizer
      Normalizer.new(attribute_mapper: attribute_mapper)
    end

    class Result
      def initialize(candidate:, result:)
        @candidate = candidate
        @result = result
      end

      delegate :name, to: :candidate
      delegate :success?, :error, to: :result

      def profile_id
        ""
      end

      private

      attr_reader :candidate, :result
    end
    private_constant :Result
  end
end
