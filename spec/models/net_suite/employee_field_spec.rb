require "rails_helper"

describe NetSuite::EmployeeField do
  describe "#label" do
    it "provides a valid label for camelCase" do
      employee_field = described_class.new(name: "homePhone", value: "foo")

      expect(employee_field.label).to eq("Home Phone")
    end

    it "provides a valid label for doubleCamelCase" do
      employee_field = described_class.new(
        name: "globalSubscriptionStatus",
        value: {}
      )

      expect(employee_field.label).to eq("Global Subscription Status")
    end

    it "provides a valid label for single words" do
      employee_field = described_class.new(name: "phone", value: "Foo")

      expect(employee_field.label).to eq("Phone")
    end
  end

  describe "#type" do
    it "provides a type" do
      employee_field = described_class.new(
        name: "email",
        value: "test@example.com"
      )

      expect(employee_field.type).to eq("email")
    end
  end
end
