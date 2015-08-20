class NamelyDuplicateFilter
  def self.filter(recent_hires, options)
    new(options).filter(recent_hires)
  end

  def initialize(normalizer:, namely_connection:)
    @normalizer = normalizer
    @namely_connection = namely_connection
  end

  def filter(unfiltered)
    unfiltered.reject do |row|
      identifier = normalizer.identifier(row)
      imported_identifiers.include?(identifier)
    end
  end

  private

  attr_reader :normalizer, :namely_connection

  def imported_identifiers
    @imported_identifiers ||= Set.new(profiles.map do |profile|
      profile.send(normalizer.namely_identifier_field)
    end)
  end

  def profiles
    namely_connection.profiles.all
  end
end
