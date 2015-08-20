class AuthenticationsController < IntegrationController
  def new
    authentication
  end

  def create
    if authentication.update(authentication_params)
      redirect_to after_create_path
    else
      render :new
    end
  end

  def edit
    authentication
  end

  def update
    if authentication.update(authentication_params)
      redirect_to dashboard_path
    else
      render :edit
    end
  end

  private

  def authentication
    @authentication ||= AuthenticationFactory.create(
      connection: connection,
      integration_id: integration_id
    )
  end

  def after_create_path
    if connection.ready?
      after_ready_path
    else
      edit_integration_connection_path(integration_id)
    end
  end

  def after_ready_path
    if connection.attribute_mapper?
      edit_integration_mapping_path(integration_id)
    else
      dashboard_path
    end
  end

  def authentication_params
    params.require(:"#{integration_id}_authentication").
      permit(authentication.allowed_parameters)
  end
end
