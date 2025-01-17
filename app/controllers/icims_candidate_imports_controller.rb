class IcimsCandidateImportsController < ApplicationController
  skip_before_filter :require_login
  skip_before_filter :verify_authenticity_token

  def create
    CandidateImporter.new(
      assistant_class: Icims::CandidateImportAssistant,
      connection: connection,
      mailer: CandidateImportMailer,
      params: params
    ).import
    render nothing: true
  end

  private

  def connection
    Icims::Connection.find_by!(
      api_key: params[:api_key],
      customer_id: params[:customerId]
    )
  end
end
