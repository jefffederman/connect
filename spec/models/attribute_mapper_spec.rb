require "rails_helper"

describe AttributeMapper do
  describe "validations" do
    it { should validate_presence_of(:mapping_direction) }
    it { should validate_presence_of(:user) }
  end
end
