class ImportResult
  delegate :[], :[]=, to: :results

  def initialize(attribute_mapper)
    @attribute_mapper = attribute_mapper
    @results = {}
  end

  def to_s(format = "%{candidate}: %{result}\n")
    results.map do |candidate, result|
      format % {
        candidate: attribute_mapper.readable_name(candidate),
        result: result,
      }
    end.join
  end

  def to_a
    results.map do |candidate, result|
      {candidate: candidate,
       result: result}
    end
  end

  private

  attr_reader :attribute_mapper, :results
end
