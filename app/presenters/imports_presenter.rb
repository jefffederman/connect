class ImportsPresenter
  def initialize(import_results)
    @import_results = import_results
  end

  def imported
    @imported ||= import_results.to_a.select do |import_result|
      import_result[:result] == I18n.t("status.success")
    end.map do |import_result|
      import_result[:candidate]
    end
  end

  def not_imported
    @not_imported ||= import_results.to_a.select do |import_result|
      import_result[:result] =~ /error/i
    end.map do |import_result|
      format_error_message(import_result)
    end
  end

  private

  attr_reader :import_results

  def format_error_message(import_result)
    import_result[:result] = import_result[:result].split(":")[-1]
    import_result
  end
end
