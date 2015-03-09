module Netsuite
  class Import
    def initialize(user, namely_importer: NamelyImporter)
      @user = user
      @namely_importer = namely_importer
    end

    def import
      namely_importer.import(
        recent_hires: netsuite_employees,
        namely_connection: namely_connection,
        attribute_mapper: AttributeMapper.new,
      )
    end

    private

    attr_reader :namely_importer, :user
    delegate :namely_connection, to: :user

    def netsuite_employees
      @netsuite_employees ||= RestClient.get(
        "http://google.com"
      )
    end
  end
end
