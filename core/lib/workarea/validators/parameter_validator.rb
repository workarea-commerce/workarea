class ParameterValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /^[\w\-]+$/
      record.errors[attribute] << <<-eos
        must contain only alphanumeric, underscore, and hyphen characters
      eos
    end
  end
end
