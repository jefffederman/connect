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

    logger.info("imported candidate for #{secret_key}")

    render json: { status: "ok" }, status: :ok
  rescue Unauthorized
    render json: { status: "accepted" }, status: :accepted
  end

  private

  def assistant_arguments
    { signature: request.headers["Signature"] }
  end

  def connection
    Greenhouse::Connection.find_by!(
      secret_key: secret_key
    )
  end

  def greenhouse_candidate_import_params
    params.fetch(:greenhouse_candidate_import)
  end

  def secret_key
    params.fetch("secret_key")
  end
end
