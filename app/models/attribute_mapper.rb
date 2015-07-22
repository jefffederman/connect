class AttributeMapper < ActiveRecord::Base
  belongs_to :user, dependent: :destroy
  has_many :field_mappings

  validates :user, presence: true
  validates :user_id, presence: true

  def build_field_mappings(default_field_mapping)
    default_field_mapping.each_pair do |namely_field, integration_field|
      field_mappings << FieldMapping.new(
        integration_field_name: integration_field.to_s,
        namely_field_name: namely_field
      )
    end
  end

  def export(profile)
    field_mappings.each_with_object({}) do |field_mapping, accumulator|
      if profile.send(field_mapping.namely_field_name).present?
        accumulator.merge!(
          field_mapping.integration_field_name => profile.send(
            field_mapping.namely_field_name
          )
        )
      end
    end
  end
end
