class Money
  alias_method :to_m, :to_money

  def as_json(*)
    Money.mongoize(self)
  end

  def to_json(*)
    as_json.to_json
  end
end

class Numeric
  alias_method :to_m, :to_money
end

class String
  alias_method :to_m, :to_money
end

class NilClass
  alias_method :to_m, :to_money
end
