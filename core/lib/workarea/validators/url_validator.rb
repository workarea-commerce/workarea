class UrlValidator < ActiveModel::EachValidator
  def self.valid_url?(value)
    !!URI.regexp(%w(http https)).match(value.to_s)
  end

  def validate_each(record, attribute, value)
    unless self.class.valid_url?(value)
      record.errors[attribute] << (options[:message] || "must be a valid")
    end
  end
end
