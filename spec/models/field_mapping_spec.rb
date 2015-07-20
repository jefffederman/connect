require 'rails_helper'

describe FieldMapping do
  describe "validations" do
    it { should validate_presence_of(:integration_field_name) }
    it { should validate_presence_of(:namely_field_name) }
    it { should validate_presence_of(:attribute_mapper) }
  end

  describe "associations" do
    it { should belong_to(:attribute_mapper).dependent(:destroy) }
  end
end
