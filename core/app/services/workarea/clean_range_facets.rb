module Workarea
  class CleanRangeFacets
    def initialize(raw)
      @raw = raw.to_h
    end

    def result
      cleaned_ranges = @raw.inject({}) do |result, (name, ranges)|
        result[name] = clean_ranges(ranges)
        result
      end

      cleaned_ranges.reject { |n, f| n.blank? || f.blank? }
    end

    private

    def clean_ranges(ranges)
      ranges
        .map do |range|
          if range['to'].present?
            range['to'] = range['to'].to_f
          else
            range.delete('to')
          end

          if range['from'].present?
            range['from'] = range['from'].to_f
          else
            range.delete('from')
          end

          range
        end
        .reject(&:blank?)
    end
  end
end
