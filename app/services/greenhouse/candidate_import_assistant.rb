module Greenhouse
  class CandidateImportAssistant
    INTEGRATION_ID = "greenhouse"

    delegate :connection, to: :context
    delegate :params, to: :context

    attr_reader :signature

    def initialize(assistant_arguments:, context:)
      @context = context
      @signature = assistant_arguments.fetch(:signature)
      @authentication_error = false
    end

    def normalizer
      Normalizer.new(
        attribute_mapper: connection.attribute_mapper,
        namely_fields: context.installation.namely_connection.fields.all
      )
    end

    def candidate
      @candidate ||= CandidateName.new(greenhouse_payload)
    end

    def import_candidate
      if ping?
        if invalid_request?
          mark_as_error_and_send_notification
        end
      else
        @import_candidate ||= context.namely_importer.single_import(
          greenhouse_payload
        )
      end
    end

    def skip_notification?
      authentication_error? || ping?
    end

    def success?
      @import_candidate.success?
    end

    private

    def authentication_error?
      @authentication_error
    end

    def person_id
      params[:personId] || params[:id]
    end

    def invalid_request?
      !Greenhouse::ValidRequesterPolicy.new(
        connection,
        signature,
        params
      ).valid?
    end

    def ping?
      greenhouse_payload.include? :web_hook_id
    end

    def greenhouse_payload
      params[:payload]
    end

    def mark_as_error_and_send_notification
      @authentication_error = true
      exception = Unauthorized.new(Unauthorized::DEFAULT_MESSAGE)
      context.notify_of_unauthorized_exception(exception)

      raise exception
    end

    attr_reader :context
  end
end
