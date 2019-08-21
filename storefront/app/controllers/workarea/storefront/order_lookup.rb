module Workarea
  module Storefront
    module OrderLookup
      extend ActiveSupport::Concern

      def lookup_order
        return @lookup_order if defined?(@lookup_order)

        @lookup_order = if session[:lookup_order_id]
                          Order.find(session[:lookup_order_id])
                        end
      end

      def lookup_order=(order)
        session[:lookup_order_id] = order.try(:id)
        @lookup_order = order
      end
    end
  end
end
