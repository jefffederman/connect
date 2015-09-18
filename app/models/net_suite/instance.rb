module NetSuite
  class Instance
    def initialize(authentication)
      @authentication = authentication
    end

    def to_h
      {
        "configuration" => {
          "user.username" => authentication.email,
          "user.password" => authentication.password,
          "netsuite.accountId" => authentication.account_id,
          "netsuite.sandbox" => false
        },
        "element" => {
          "key" => "netsuiteerp"
        },
        "tags" => [],
        "name" => name
      }
    end

    private

    attr_reader :authentication

    def name
      [
        Rails.env,
        Time.current.to_s(:number),
        authentication.account_id,
        "netsuite"
      ].join("_")
    end
  end
end
