class EmailValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    return if value.blank?

    begin
      address = Mail::Address.new(value)
      valid = valid_domain?(address) && value.include?(address.address)
    rescue Mail::Field::ParseError
      valid = false
    end
    record.errors.add(attribute) unless valid
  end

  private

  def valid_domain?(address)
    address.domain && has_top_level_domain?(address)
  end

  def has_top_level_domain?(address)
    address.domain =~ /\..+/
  end
end
