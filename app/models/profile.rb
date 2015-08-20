class Profile
  delegate :update, to: :namely_profile

  def initialize(namely_profile)
    @namely_profile = namely_profile
  end

  def name
    "#{namely_profile[:first_name]} #{namely_profile[:last_name]}"
  end

  def [](key)
    flatten_hash namely_profile[key]
  end

  private

  def flatten_hash(value)
    if value.respond_to?(:to_hash)
      value.to_hash["title"] || value.to_hash["name"]
    else
      value
    end
  end

  attr_reader :namely_profile
end
