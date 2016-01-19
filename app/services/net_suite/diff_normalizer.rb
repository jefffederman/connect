class NetSuite::DiffNormalizer

  def initialize(employee)
    @employee = employee.deep_dup
  end

  def self.normalize(employee)
    new(employee).normalize
  end

  def normalize
    normalize_address
    normalize_phone_numbers

    employee
  end


  private

  attr_reader :employee

  def normalize_phone_numbers
    %w( mobilePhone officePhone phone ).each do |phone_key|
      next unless employee[phone_key].present?

      number = GlobalPhone.parse(employee[phone_key])
      employee[phone_key] = number.national_format
    end
  rescue StandardError => e
    Rails.logger.info "normalize failure: #{employee.to_json}"
    Rails.logger.info "tracking exception"
    Raygun.track_exception(e)
  end

  def normalize_address
    employee["defaultAddress"] = ""

    if (addressbook_list = employee["addressbookList"]) &&
       (address_book = addressbook_list["addressbook"])

      default_address = address_book.find do |address|
        address["defaultShipping"] == true
      end

      if default_address.present? && address = default_address["addressbookAddress"]
        #TODO: Handle country!
        employee["defaultAddress"] = "#{ address["addr1"] }<br>#{ address["addr2"] }<br>#{ address["city"] } #{ address["state"] } #{ address["zip"] }<br>United States"
      end
    end
  end
end
