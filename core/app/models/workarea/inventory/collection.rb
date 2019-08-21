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

      def self.statuses
        Workarea.config.inventory_status_calculators.map do |klass|
          klass.demodulize.underscore
        end
      end

      statuses.each do |status_name|
        define_method "#{status_name}?" do
          status.to_s == status_name
        end
      end

      # The total number available to sell
      #
      # return [Integer]
      #
      def available_to_sell
        records.map(&:available_to_sell).sum
      end

      # If the product has any puchasable inventory
      #
      # return [Boolean]
      #
      def purchasable?(quantity = 1)
        quantity <= available_to_sell
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

      # Get the status of this collection of inventory skus.
      #
      # @return [Symbol]
      #
      def status
        calculators = Workarea.config.inventory_status_calculators.map(&:constantize)
        StatusCalculator.new(calculators, self).result
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
