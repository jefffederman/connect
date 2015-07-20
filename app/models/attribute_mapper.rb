class AttributeMapper < ActiveRecord::Base
  belongs_to :user, dependent: :destroy
  has_many :field_mappings

  validates :mapping_direction, presence: true
  validates :user, presence: true
  validates :user_id, presence: true
end
