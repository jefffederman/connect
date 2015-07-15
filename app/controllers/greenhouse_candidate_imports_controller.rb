class GreenhouseCandidateImportsController < ApplicationController
  skip_before_filter :require_login
  skip_before_filter :verify_authenticity_token

  def create
    CandidateImporter.new(
      assistant_arguments: assistant_arguments,
      assistant_class: Greenhouse::CandidateImportAssistant,
      connection: connection,
      mailer: CandidateImportMailer,
      params: greenhouse_candidate_import_params,
    ).import

    render nothing: true, status: :ok
  rescue Unauthorized
    render nothing: true, status: :unauthorized
  end

  private

  def assistant_arguments
    { signature: request.headers["Signature"] }
  end

  def connection
    Greenhouse::Connection.find_by(
      secret_key: params.fetch("secret_key")
    ) or raise Unauthorized.new(Unauthorized::DEFAULT_MESSAGE)
  end

  def greenhouse_candidate_import_params
    params.fetch(:greenhouse_candidate_import)
  end
end
