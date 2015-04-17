class NamelyJobTitle
  UNKNOWN_JOB = "unknown job tier"

  def initialize(job_title_name:, namely_connection:)
    @job_title_name = job_title_name
    @namely_connection = namely_connection
  end

  def job_title
    namely_connection.job_tiers.all
  end

  private

  def job_tiers
    @job_tiers ||= namely_connection.job_tiers
  end

  attr_reader :job_title_name, :namely_connection
end
