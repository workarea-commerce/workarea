module Workarea
  module CalculatePercentChange
    def calculate_percent_change(first, second)
      return nil if first.blank? || first.zero?
      ((second.to_f - first) / first.to_f) * 100
    end
  end
end
