class Money
  module BlankMongoizing
    def mongoize(value)
      return nil if value.blank?
      super(value)
    end
  end

  class << self
    prepend BlankMongoizing

    # money-rails calls `deep_symbolize_keys!` on any hash-like input.
    # With bson >= 5 this emits a deprecation warning (and will raise in v6)
    # when the input is a BSON::Document.
    private

    def mongoize_hash(hash)
      hash = hash.to_h if defined?(::BSON::Document) && hash.is_a?(::BSON::Document)

      if hash.respond_to?(:deep_symbolize_keys!)
        hash.deep_symbolize_keys!
      elsif hash.respond_to?(:symbolize_keys!)
        hash.symbolize_keys!
      end

      return nil if hash[:cents] == '' && hash[:currency_iso] == ''

      ::Money.new(hash[:cents], hash[:currency_iso]).mongoize
    end
  end

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
