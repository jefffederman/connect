class IcimsCandidateRetryImportsController < ApplicationController
  def show
    service = CandidateImporter.new(
      assistant_class: Icims::CandidateImportAssistant,
      connection: connection,
      mailer: CandidateImportMailer,
      params: params
    )

    service.import
    @candidate_retry_presenter = Icims::CandidateRetryImportsPresenter.new(
      service.import_assistant.candidate,
      service.import_assistant.import_candidate
    )
  end

  private

  def namely_importer
    NamelyImporter.new(
      namely_connection: current_user.namely_connection,
      normalizer: Icims::Normalizer.new,
    )
  end

  def connection
    current_user.icims_connection
  end

end
