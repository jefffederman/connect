class MappingsController < IntegrationController
  def edit
    @attribute_mapper = connection.attribute_mapper
  end

  def update
    @attribute_mapper = connection.attribute_mapper

    if @attribute_mapper.update(attribute_mapper_params)
      redirect_to dashboard_path
    else
      render "edit"
    end
  end

  private

  def attribute_mapper_params
    params.require(:attribute_mapper).
      permit(field_mappings_attributes: [:namely_field_name, :id])
  end
end
