module Workarea
  module DetailsHelper
    def formatted_item_details(details)
      details
        .map do |name, value|
          joined = value.is_a?(Array) ? value.join(', ') : value
          "#{name}: #{joined}"
        end
        .join(', ')
    end
  end
end
