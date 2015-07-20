require "rails_helper"

describe AttributeMapper do
  describe "validations" do
    it { should validate_presence_of(:mapping_direction) }
    it { should validate_presence_of(:user) }
  end

  describe "associations" do
    it { should belong_to(:user).dependent(:destroy) }
    it { should have_many(:field_mappings) }
  end
end
