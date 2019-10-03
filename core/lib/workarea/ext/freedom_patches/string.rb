# frozen_string_literal: true

class String
  #
  # These two methods are to cut down on object allocation
  #

  def self.optionize_unwanted_chars_regex
    @optionize_unwanted_chars_regex ||= /[^a-z0-9\-_]+/
  end

  def self.optionize_seperator_regexes
    @optionize_seperator_regexes ||= {}
  end

  def optionize(sep = '-')
    result = downcase
    result.strip!

    # Turn unwanted chars into the separator
    result.gsub!(String.optionize_unwanted_chars_regex, sep)

    # No more than one of the separator in a row.
    String.optionize_seperator_regexes[sep] ||= /#{Regexp.escape(sep)}{2,}/
    result.gsub!(String.optionize_seperator_regexes[sep], sep)

    result.underscore
  end
  alias_method :slugify, :optionize
  alias_method :systemize, :optionize
end
