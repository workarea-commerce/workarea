module Workarea
  module Inventory
    class InsufficientError < RuntimeError; end

    # Whether any of the passed SKUs should be displayed
    # in search. Used when indexing a product and deciding
    # whether to show that product.
    #
    # @return [Boolean]
    #
    def self.displayable?(*skus)
      arr = Array(skus).flatten
      set = Inventory::Collection.new(arr)
      set.empty? || set.any?(&:displayable?)
    end

    # Checks whether any of a set of SKUs are available
    #
    # @param skus [Array]
    # @return [Boolean]
    #
    def self.any_available?(*skus)
      arr = Array(skus).flatten
      set = Inventory::Collection.new(arr)
      set.empty? || set.any?(&:purchasable?)
    end

    # Gets the total number of sales for a set of SKUs
    #
    # @param skus [Array]
    # @return [Integer]
    #
    def self.total_sales(*skus)
      arr = Array(skus).flatten
      Inventory::Collection.new(arr).sum(&:purchased)
    end

    # Get total count of units available to sell
    #
    # @param skus [Array]
    # @return [Integer]
    #
    def self.total_available(*skus)
      arr = Array(skus).flatten
      Inventory::Collection.new(arr).sum(&:available)
    end

    # Find a set of insuffciencies for a set of items.
    # Used for adjusting a cart when full quantities aren't available.
    #
    # @param items [Hash] keys are SKUs, values are quantities
    # @return [Hash]
    #   a hash with keys of SKUs and values of how many short the inventory is
    #
    def self.find_insufficiencies(items)
      set = Inventory::Collection.new(items.keys)

      items.inject({}) do |memo, item|
        sku, quantity = *item
        record = set.for_sku(sku)

        if record
          memo[sku] = record.insufficiency_for(quantity)
        else
          memo[sku] = 0
        end

        memo
      end
    end
  end
end
