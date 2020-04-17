module Workarea
  class HashUpdate
    def self.parse_values(value)
      parsed = CSV.parse(value).first
      parsed.map(&:to_s).map(&:strip).reject(&:blank?) if parsed.present?
    end

    def initialize(original: {}, adds: [], updates: [], removes: [])
      @original = original
      @adds = Array(adds).flatten.each_slice(2).to_a
      @updates = Array(updates).flatten.each_slice(2).to_a
      @removes = Array(removes).flatten
    end

    def result
      apply_to(@original.deep_dup)
    end

    # TODO v3.6 remove this method, doesn't work when the field is localized
    # @deprecated
    def apply(hash)
      warn <<~eos
        [DEPRECATION] `HashUpdate#apply` is deprecated and will be removed in
        version 3.6.0. Please use `HashUpdate#result` instead.
      eos
      apply_to(hash)
    end

    private

    def apply_to(hash)
      @adds.each do |tuple|
        key, value = *tuple
        hash[key] = self.class.parse_values(value)
      end

      @updates.each do |tuple|
        key, value = *tuple
        hash[key] = self.class.parse_values(value)
      end

      @removes.each do |key|
        hash.delete(key)
      end

      hash.delete_if { |k, v| k.blank? || v.blank? }
    end
  end
end
