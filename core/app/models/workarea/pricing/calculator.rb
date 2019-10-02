module Workarea
  module Pricing
    module Calculator
      extend ActiveSupport::Concern

      class TestRequest < Request
        def order
          @persisted_order
        end

        def shippings
          @persisted_shippings
        end

        def payment
          @persisted_payment
        end
      end

      included do
        attr_reader :request
        delegate :order, :shippings, :payment, :pricing, :discounts, to: :request
      end

      module ClassMethods
        def test_adjust(order, shippings = nil)
          request = TestRequest.new(order, Array(shippings))
          new(request).adjust
        end
      end

      def initialize(request)
        @request = request
      end

      def adjust
        raise(NotImplementedError, "#{self.class} must implement #adjust")
      end
    end
  end
end
