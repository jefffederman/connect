module Netsuite
  class Import
    def initialize(user, namely_importer: NamelyImporter)
      @user = user
      @namely_importer = namely_importer
    end

    def import
      namely_importer.import(
        recent_imports: netsuite_employees,
        namely_connection: namely_connection,
        attribute_mapper: AttributeMapper.new,
      )
    end

    private

    attr_reader :namely_importer, :user
    delegate :namely_connection, to: :user

    def netsuite_employees
      @netsuite_employees ||= fetch_netsuite_employees.collect do |employee|
        Employee.new(employee)
      end
    end

    def fetch_netsuite_employees
      result = RestClient.get(ENV["NETSUITE_GATEWAY_URL"])
      JSON.parse(result).first["employees"]
    end
  end
end
