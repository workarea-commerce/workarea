# TODO: Extract out into separate gem for v3
class PasswordValidator < ActiveModel::EachValidator
  MIN_LENGTHS = {
    weak: 7,
    medium: 7,
    strong: 8
  }

  REGEXES = {
    weak:   %r[(?=.{#{MIN_LENGTHS[:weak]},}).*], # 7 characters
    medium: %r[^(?=.{#{MIN_LENGTHS[:medium]},})(((?=.*[A-Z])(?=.*[a-z]))|((?=.*[A-Z])(?=.*[0-9]))|((?=.*[a-z])(?=.*[0-9]))).*$], # len=7 chars and numbers
    strong: %r[^.*(?=.{#{MIN_LENGTHS[:strong]},})(?=.*[a-z])(?=.*[A-Z])(?=.*[\d\W]).*$] # len=8 chars and numbers and special chars
  }

  def validate_each(record, attribute, value)
    return if value.blank?

    required_strength = options.fetch(:strength, :weak)

    if !required_strength.in?(REGEXES.keys) && record.respond_to?(required_strength)
      required_strength = record.send(required_strength)
    end

    if REGEXES[required_strength] !~ value
      record.errors.add(
        attribute,
        "password_#{required_strength}_requirements".to_sym,
        min: MIN_LENGTHS[required_strength]
      )
    end
  end
end
