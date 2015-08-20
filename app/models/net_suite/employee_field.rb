module NetSuite
  class EmployeeField
    attr_reader :id, :name, :value

    def initialize(id:, name:, value:)
      @id = id
      @name = name
      @value = value
    end

    def label
      name.titleize
    end

    def type
      TypeForField.for_field(name: name, value: value)
    end
  end
end
