class AttributeMapper < ActiveRecord::Base
  SUPPORTED_TYPES = %w(
    date
    email
    longtext
    referencehistory
    referenceselect
    select
    text
  )
  # Unsupported: address checkboxes file image salary

  has_many :field_mappings, dependent: :destroy

  accepts_nested_attributes_for :field_mappings

  def export(profile)
    field_mappings.each_with_namely_field do |field_mapping, accumulator|
      value = profile[field_mapping.namely_field_name]
      if value.present?
        accumulator.merge!(field_mapping.integration_field_id => value)
      end
    end
  end

  def import(attributes)
    field_mappings.each_with_namely_field do |field_mapping, accumulator|
      value = attributes[field_mapping.integration_field_id.to_sym]
      if value.present?
        accumulator.merge!(field_mapping.namely_field_name.to_sym => value)
      end
    end
  end
end
