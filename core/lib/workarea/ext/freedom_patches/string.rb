class String
  def optionize(sep = '-')
    result = downcase.strip

    # Turn unwanted chars into the separator
    result.gsub!(/[^a-z0-9\-_]+/, sep)
    re_sep = Regexp.escape(sep)

    # No more than one of the separator in a row.
    result.gsub!(/#{re_sep}{2,}/, sep)

    result.underscore
  end
  alias_method :slugify, :optionize
  alias_method :systemize, :optionize
end
