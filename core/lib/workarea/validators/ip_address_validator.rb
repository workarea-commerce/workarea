class IpAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank? or IPAddress.valid?(value)
      record.errors[attribute] << 'must be a valid IP address.'
    end
  end
end
