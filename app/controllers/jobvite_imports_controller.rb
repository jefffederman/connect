class JobviteImportsController < ApplicationController
  def create
    jobvite_import = Jobvite::Import.new(current_user)
    @jobvite_imports_presenter = ImportsPresenter.new(jobvite_import.import)
  end
end
