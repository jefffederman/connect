module Icims
  class CandidateImportAssistant
    INTEGRATION_ID = "icims"

    delegate :connection, to: :context
    delegate :params, to: :context

    def initialize(context:, **_)
      @context = context
      @authentication_error = false
    end

    def normalizer
      Normalizer.new
    end

    def candidate
      @candidate ||= Icims::Client.new(connection).candidate(person_id)
    end

    def import_candidate
      @import_candidate ||= context.namely_importer.single_import(candidate)
    rescue Icims::Client::Error => exception
      @authentication_error = true
      context.notify_of_unauthorized_exception(exception)
    end

    def success?
      @import_candidate.success?
    end

    def skip_notification?
      authentication_error?
    end

    private

    def authentication_error?
      @authentication_error
    end

    def person_id
      params[:personId] || params[:id]
    end

    attr_reader :context
  end
end
