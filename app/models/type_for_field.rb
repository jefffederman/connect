class TypeForField
  def self.for_field(name:, value:)
    new(name: name, value: value).determine_type
  end

  def initialize(name:, value:)
    @name = name
    @value = value
  end

  def determine_type
    case
    when boolean?; "boolean"
    when date?; "date"
    when email?; "email"
    when fixnum?; "fixnum"
    when object?; "object"
    when text?; "text"
    end
  end

  private

  def boolean?
    value.class == TrueClass || value.class == FalseClass
  end

  def date?
    value.class == Fixnum && name.match(/Date/)
  end

  def email?
    value.class == String && name.match(/email/)
  end

  def fixnum?
    value.class == Fixnum && !name.match(/Date/)
  end

  def object?
    value.class == Hash
  end

  def text?
    value.class == String
  end

  attr_reader :name, :value
end
