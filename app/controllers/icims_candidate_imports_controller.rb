class IcimsCandidateImportsController < ApplicationController
  skip_before_filter :require_login
  skip_before_filter :verify_authenticity_token

  def create
    importer.import
    render nothing: true
  end

  private

  def importer
    connection.build_candidate_importer(
      assistant_class: Icims::CandidateImportAssistant,
      connection: connection,
      mailer: CandidateImportMailer,
      params: params
    )
  end

  def connection
    Icims::Connection.for_api_key(
      api_key: params[:api_key],
      customer_id: params[:customerId]
    )
  end
end
