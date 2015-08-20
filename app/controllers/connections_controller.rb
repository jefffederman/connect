class ConnectionsController < IntegrationController
  def edit
    connection
  end

  def update
    if update_connection
      redirect_to after_update_path
    else
      render :edit
    end
  end

  def destroy
    connection.destroy
    redirect_to dashboard_path
  end

  private

  def update_connection
    connection.update(connection_params) && connection.ready?
  end

  def connection_params
    params.require(connection_type).permit(connection.allowed_parameters)
  end

  def after_update_path
    if connection.attribute_mapper?
      edit_integration_mapping_path(integration_id)
    else
      dashboard_path
    end
  end
end
