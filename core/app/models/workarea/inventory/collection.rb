module Workarea
  module Inventory
    # This class represents a collection of {Sku}s. It is more
    # performant because it does a single query to grab the
    # {Sku}s instead of N+1.
    #
    class Collection
      include Enumerable
      attr_reader :skus
      delegate :any?, :empty?, :each, :size, :length, to: :records

      def initialize(skus, records = nil)
        @skus = skus
        @records = records
      end

      # The total number available to sell
      #
      # return [Integer]
      #
      def available_to_sell
        records.map(&:available_to_sell).sum
      end

      # Grab the specific {Sku} for a SKU.
      # Returns a new, unpersisted {Sku} if one does not exist.
      #
      # @param sku [String]
      # @return [Sku]
      #
      def for_sku(sku)
        records.detect { |r| r.id == sku }
      end

      def policies
        records.map(&:policy)
      end

      def records
        @records ||=
          begin
            existing = Sku.in(id: skus).to_a
            missing_skus = skus - existing.map(&:id)

            existing + missing_skus.map { |sku| Sku.new(id: sku ) }
          end
      end
    end
  end
end
