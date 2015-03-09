class NetsuiteImportsController < ApplicationController
  def create
    @netsuite_import = Netsuite::Import.new(current_user).import
  end
end
