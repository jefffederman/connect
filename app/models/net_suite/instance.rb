module NetSuite
  class Instance
    def initialize(authentication:)
      @authentication = authentication
    end

    def to_h
      {
        "configuration" => {
          "user.username" => authentication.email,
          "user.password" => authentication.password,
          "netsuite.accountId" => authentication.account_id,
          "netsuite.sandbox" => false,
          "netsuite.sso.roleId" => "3",
          "netsuite.appId" => authentication.app_id,
          "netsuite.sso.companyId" => authentication.company_id,
          "netsuite.sso.userId" => authentication.user_id,
          "netsuite.sso.partnerId" => authentication.partner_id,
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
