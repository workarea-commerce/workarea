module Workarea
  module Admin
    class FulfillmentItemViewModel < ApplicationViewModel
      def events
        options[:events] || []
      end

      def quantity
        options[:quantity] || events.sum(&:quantity)
      end
    end
  end
end
