module Workarea
  module Pricing
    # This class is responsible for evenly (or as best as possible)
    # distributing a price across a variable number of units.
    #
    # This is used to prevent rounding errors when adding
    # price adjustments for order level prices across
    # items.
    #
    class PriceDistributor
      delegate :[], :each, to: :results

      # Get an instance of {PriceDistributor} for a
      # price and a given set of items. Transforms the
      # items into an array of unit hashes, which are
      # how this class calculates.
      #
      # @param [Money] price
      # @param [Array<Workarea::Order::Item>] items
      # @return [PriceDistributor]
      #
      def self.for_items(price, items)
        units = []

        items.each do |item|
          item.quantity.times do
            units << { id: item.id, price: item.current_unit_price }
          end
        end

        new(price, units)
      end

      def initialize(total_value, units)
        @total_value = total_value
        @units = units
        @total_price = units.sum { |u| u[:price] }
      end

      # The results of the distribution in a hash, where
      # key is the unit id and value is the that id's share
      # of the price.
      #
      # @return [Hash]
      #
      def results
        @results ||= if can_distribute?
                       distributed_results
                     else
                       empty_results
                     end
      end

      private

      def can_distribute?
        !@total_value.to_f.zero? && @total_price.to_f > 0
      end

      def distributed_results
        tmp = Hash.new(0.to_m)

        @units.each do |unit|
          next if @total_value.to_f.zero? ||
                  unit[:price].to_f.zero? ||
                  @total_price.to_f.zero?

          unit_value = @total_value.to_f *
            (unit[:price].to_f / @total_price.to_f)

          @total_price -= unit[:price]
          @total_value -= unit_value.to_m

          tmp[unit[:id]] += unit_value.to_m
        end

        tmp
      end

      def empty_results
        @units.inject({}) do |memo, unit|
          memo[unit[:id]] ||= 0.to_m
          memo
        end
      end
    end
  end
end
