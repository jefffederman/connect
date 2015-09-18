class Profile
  delegate :update, to: :namely_profile

  def initialize(namely_profile, fields:)
    @namely_profile = namely_profile
    @fields = fields
  end

  def id
    @namely_profile[:id]
  end

  def name
    "#{namely_profile[:first_name]} #{namely_profile[:last_name]}"
  end

  def [](key)
    @fields.export(key, from: @namely_profile)
  end

  private

  attr_reader :namely_profile
end
