module Workarea
  class HashUpdate
    def self.parse_values(value)
      parsed = CSV.parse(value).first
      parsed.map(&:to_s).map(&:strip).reject(&:blank?) if parsed.present?
    end

    def initialize(adds: [], updates: [], removes: [])
      @adds = Array(adds).flatten.each_slice(2).to_a
      @updates = Array(updates).flatten.each_slice(2).to_a
      @removes = Array(removes).flatten
    end

    def apply(hash)
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
