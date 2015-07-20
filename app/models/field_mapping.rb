class FieldMapping < ActiveRecord::Base
  belongs_to :attribute_mapper, dependent: :destroy

  validates :attribute_mapper, presence: true
  validates :attribute_mapper_id, presence: true
  validates :integration_field_name, presence: true
  validates :namely_field_name, presence: true
end
