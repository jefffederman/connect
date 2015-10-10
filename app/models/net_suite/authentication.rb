module NetSuite
  class Authentication
    include ActiveModel::Model
    extend Forwardable

    attr_accessor :account_id, :email, :password

    validates :account_id, presence: true
    validates :email, presence: true
    validates :password, presence: true

    def initialize(connection:, client:)
      @connection = connection
      @installation = connection.installation
      @client = client
    end

    def allowed_parameters
      [:account_id, :email, :password]
    end

    def update(attributes)
      self.attributes = attributes
      valid? && create_instance
    end

    def user_id
      @installation.namely_user_id
    end

    def company_id
      @installation.subdomain
    end

    def app_id
      @client.app_id
    end

    def partner_id
      @client.partner_id
    end

    private

    def create_instance
      result = @client.create_instance(self)
      @connection.update!(
        instance_id: result["id"],
        authorization: result["token"]
      )
      true
    rescue NetSuite::ApiError => exception
      errors.add(:base, exception.message)
      false
    end

    def attributes
      {
        account_id: account_id,
        email: email,
        password: password
      }
    end

    def attributes=(attributes)
      self.account_id = attributes[:account_id]
      self.email = attributes[:email]
      self.password = attributes[:password]
    end
  end
end
