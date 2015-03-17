module Jobvite
  class Import
    def initialize(
      user,
      jobvite_client: Jobvite::Client,
      namely_importer: NamelyImporter
    )
      @user = user
      @jobvite_client = jobvite_client
      @namely_importer = namely_importer
    end

    def import
      if jobvite_connection.connected?
        import_recent_hires
      else
        I18n.t("status.not_connected")
      end
    end

    private

    attr_reader :jobvite_client, :namely_importer, :user
    delegate :jobvite_connection, :namely_connection, to: :user

    def import_recent_hires
      namely_importer.import(
        recent_imports: recent_hires,
        namely_connection: namely_connection,
        attribute_mapper: AttributeMapper.new,
      )
    rescue Jobvite::Client::Error => e
      I18n.t("status.jobvite_error", message: e.message)
    rescue Namely::FailedRequestError => e
      I18n.t("status.namely_error", message: e.message)
    end

    def recent_hires
      @recent_hires ||= jobvite_client.recent_hires(jobvite_connection)
    end
  end
end
