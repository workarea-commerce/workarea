module Workarea
  module Pricing
    class Discount
      # This class exists mostly for performance. It gets a list
      # of discounts and caches that list so qualification does not have to
      # fetch from the database over and over again.
      #
      class Collection
        include Enumerable

        delegate :each, :select, :reject, :to_set, to: :all

        # TODO remove in v4, unused
        def self.expire_cache
          Rails.cache.delete('discounts_cache')
        end

        # All currently active discounts.
        #
        # @return [Array<Discount>]
        #
        def all
          @all ||= Pricing::Discount
            .all
            .to_a
            .select(&:active?)
            .sort
        end

        # Find a discount by id.
        #
        # @param [String] id
        # @return [Discount, nil]
        #
        def find(id)
          all.detect { |discount| discount.id.to_s == id.to_s }
        end

        # Find an array of discounts that are instances of
        # the passed class.
        #
        # @param [Class] klass
        # @return [Array<Discount>]
        #
        def find_by_class(klass)
          all.select { |discount| discount.class == klass }
        end

        # Get a compiled list of SKUs from all discounts. Useful
        # when trying to lookup all SKUs for a pricing request at once
        # (for performance).
        #
        # @return [Array<String>]
        #
        def skus
          all.select { |d| d.respond_to?(:sku) }.map(&:sku)
        end
      end
    end
  end
end
