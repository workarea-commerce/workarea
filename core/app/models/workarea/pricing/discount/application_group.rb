module Workarea
  module Pricing
    class Discount
      class ApplicationGroup
        attr_reader :discounts, :order, :shippings

        class << self
          def calculate(discounts, order, shippings)
            expiration = Workarea.config.cache_expirations.discount_application_groups
            groups = Rails.cache.fetch(current_cache_key, expires_in: expiration, race_condition_ttl: 10) do
              # Ensure an undirected graph of compatibility on discounts
              discounts.each do |discount|
                discount.compatible_discount_ids.each do |id|
                  compatible_discount = discounts.detect { |d| d.id.to_s == id }
                  next unless compatible_discount.present?

                  # compatible_discounts should be the open neighborhood of the
                  # discount i.e. it shouldn't include itself
                  unless compatible_discount == discount
                    discount.compatible_discounts << compatible_discount
                    compatible_discount.compatible_discounts << discount
                  end
                end
              end

              results = []
              build_groups(remaining: discounts.to_set, results: results)
              results
            end

            groups.map { |set| new(set.to_a, order, shippings) }
          end

          def current_cache_key
            [
              'discount_application_groups',
              Release.current&.id,
              *Segment.current.map(&:id).sort
            ].compact.join('/')
          end

          private

          # Implementation of Bron-Kerbosh algorithm with pivoting:
          # https://en.wikipedia.org/wiki/Bron%E2%80%93Kerbosch_algorithm
          #
          # Bulds the result array param into the unique compatible groups.
          #
          def build_groups(results: [], potential_group: Set.new, remaining: Set.new, skip: Set.new)
            # Nothing left to try, this is a compatible group
            if remaining.empty? && skip.empty?
              results << potential_group
              return
            end

            pivot = remaining.to_a.sample || skip.to_a.sample
            non_neighbors = remaining - pivot.compatible_discounts

            non_neighbors.each do |discount|
              # Try adding the discount to the potential_group to see if works.
              new_potential_group = potential_group + [discount]
              new_remaining = remaining & discount.compatible_discounts
              new_skip = skip & discount.compatible_discounts

              build_groups(
                potential_group: new_potential_group,
                remaining: new_remaining,
                skip: new_skip,
                results: results
              )

              # Done with this discount. If there was a way to form a valid
              # group with it, we added it to result it in the recursive call
              # above. So remove it from the list of remaining nodes and add it
              # to the skip list.
              remaining -= [discount]
              skip += [discount]
            end
          end
        end

        def initialize(discounts, order, shippings)
          @discounts = discounts.sort
          @order = order
          @shippings = shippings
        end

        def apply
          discounts.each do |discount|
            discount_order = Discount::Order.new(order, shippings, discount)
            next unless discount.qualifies?(discount_order)

            discount.apply(discount_order)
          end
        end

        def value
          @value ||=
            begin
              apply
              result = calculate_applied_value
              remove_discounts
              result
            end.to_m
        end

        private

        def calculate_applied_value
          all_price_adjustments
            .flatten
            .select(&:discount?)
            .map { |pa| pa.data['discount_value'].to_m }
            .sum
            .abs
        end

        def all_price_adjustments
          order.price_adjustments + shippings.map(&:price_adjustments).flatten
        end

        def remove_discounts
          discounts.each do |discount|
            discount_order = Discount::Order.new(order, shippings, discount)
            discount.remove_from(discount_order)
          end
        end
      end
    end
  end
end
