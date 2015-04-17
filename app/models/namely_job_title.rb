class NamelyJobTitle
  UNKNOWN_JOB = "unknown job tier"

  def initialize(job_title_name:, namely_connection:)
    @job_title_name = job_title_name
    @namely_connection = namely_connection
  end

  def job_title
    detect_job_title.id
  end

  private

  def detect_job_title
    job_titles.detect { |job_title| job_title.title == job_title_name }
  end

  def job_titles
    @job_titles ||= namely_connection.job_titles.all
  end

  attr_reader :job_title_name, :namely_connection
end
