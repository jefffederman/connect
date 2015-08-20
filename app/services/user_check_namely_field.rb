class UserCheckNamelyField < SimpleDelegator
  def missing_namely_field?
    disconnected? || does_not_have_field?
  end

  private

  def disconnected?
    !connected?
  end

  def does_not_have_field?
    !has_field?
  end

  def has_field?
    found_namely_field? || has_cached_remote_field?
  end

  def has_cached_remote_field?
    if has_remote_field?
      update(found_namely_field: true)
      true
    else
      false
    end
  end

  def has_remote_field?
    namely_connection.fields.all.any? do |field|
      field.name == required_namely_field.to_s
    end
  end

  def namely_connection
    installation.namely_connection
  end
end
