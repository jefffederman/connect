class FieldMapping < ActiveRecord::Base
  belongs_to :attribute_mapper

  validates :attribute_mapper, presence: true
  validates :attribute_mapper_id, presence: true
  validates :integration_field_name, presence: true

  def self.map!(id, name: nil, to: nil)
    if where(integration_field_id: id).empty?
      create!(
        integration_field_id: id,
        integration_field_name: name,
        namely_field_name: to
      )
    end
  end

  def self.each_with_namely_field
    all.each_with_object({}) do |field_mapping, result|
      if field_mapping.namely_field_name?
        yield field_mapping, result
      end
    end
  end

  def integration_key
    integration_field_name.underscore.parameterize("_")
  end
end
