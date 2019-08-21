class Country
  def self.search_for(value)
    all.detect do |country|
      country.alpha2.casecmp?(value.to_s) ||
        country.alpha3.casecmp?(value.to_s) ||
        country.name.casecmp?(value.to_s) ||
        country.unofficial_names.any? { |name| name.casecmp?(value.to_s) }
    end
  end

  # Without this, any Country objects put in JSON render much verbose
  def as_json(*)
    alpha2
  end
end
