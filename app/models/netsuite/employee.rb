module Netsuite
  class Employee < OpenStruct
    def initialize(attributes)
      super attributes.map { |k,v| [k.underscore, v] }.to_h
    end

    def name
      "#{self["first_name"]} #{self["last_name"]}"
    end
  end
end
