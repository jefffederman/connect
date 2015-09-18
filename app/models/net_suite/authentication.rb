module NetSuite
  class Authentication
    include ActiveModel::Model

    attr_accessor :account_id, :email, :password

    validates :account_id, presence: true
    validates :email, presence: true
    validates :password, presence: true

    def initialize(connection:, client:)
      @connection = connection
      @client = client
    end

    def allowed_parameters
      [:account_id, :email, :password]
    end

    def update(attributes)
      self.attributes = attributes
      valid? && create_instance
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
