class ParameterValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /^[\w\-]+$/
      record.errors.add(attribute, "must contain only alphanumeric, underscore, and hyphen characters")
    end
  end
end
