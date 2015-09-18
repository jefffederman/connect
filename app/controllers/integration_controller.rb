class IntegrationController < ApplicationController
  private

  def connection
    @connection ||= current_user.installation.connection_to(integration_id)
  end

  def integration_id
    params[:integration_id]
  end

  helper_method :integration_id
end
