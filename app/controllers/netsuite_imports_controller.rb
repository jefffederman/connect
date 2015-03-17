class NetsuiteImportsController < ApplicationController
  def create
    @netsuite_import = Netsuite::Import.new(current_user).import
    @netsuite_imports_presenter = Jobvite::ImportsPresenter.new(@netsuite_import)
  end
end
