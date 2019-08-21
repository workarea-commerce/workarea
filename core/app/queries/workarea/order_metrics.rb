module Workarea
  class OrderMetrics
    attr_reader :order
    delegate_missing_to :order

    def initialize(order)
      @order = order
    end

    def occured_at
      order.placed_at
    end

    def user
      @user ||= Metrics::User.find_or_initialize_by(id: email)
    end

    def first_time_customer?
      user.orders.zero?
    end

    def repeat_today?
      user.last_order_at.present? && user.last_order_at.today?
    end

    def sales_data
      @sales_data ||= begin
        based_on_items = calculate_based_on_items(items)

        {
          orders: 1,
          returning_orders: first_time_customer? ? 0 : 1,
          customers: repeat_today? ? 0 : 1,
          units_sold: quantity,
          discounted_units_sold: based_on_items[:discounted_units_sold],
          merchandise: based_on_items[:merchandise],
          discounts: discount_adjustments.sum,
          shipping: shipping_before_discounts,
          tax: tax_total,
          revenue: total_price
        }
      end
    end

    def user_data
      {
        email: email,
        revenue: total_price,
        discounts: sales_data[:discounts],
      }
    end

    def shipping_before_discounts
      all_price_adjustments
        .select { |pa| pa.price == 'shipping' }
        .reject(&:discount?)
        .map(&:amount)
        .sum
    end

    def products
      @products ||= order.items.group_by(&:product_id).transform_values do |items|
        calculate_based_on_items(items)
      end
    end

    def categories
      @categories ||= items_by_via
        .select { |gid| gid.model_class.name == 'Workarea::Catalog::Category' }
        .transform_keys(&:model_id)
    end

    def searches
      @searches ||= items_by_via
        .select { |gid| gid.model_class.name == 'Workarea::Navigation::SearchResults' }
        .reduce({}) do |memo, (gid, data)|
          query_id = gid.find.query_string.id

          memo[query_id] ||= Hash.new(0)
          memo[query_id][:orders] = 1

          memo[query_id][:units_sold] += data[:units_sold]
          memo[query_id][:discounted_units_sold] += data[:discounted_units_sold]
          memo[query_id][:merchandise] += data[:merchandise]
          memo[query_id][:discounts] += data[:discounts]
          memo[query_id][:tax] += data[:tax]
          memo[query_id][:revenue] += data[:revenue]
          memo
        end
    end

    def skus
      @skus ||= order.items.group_by(&:sku).transform_values do |items|
        calculate_based_on_items(items)
      end
    end

    def menus
      @menus ||= categories.reduce({}) do |memo, (category_id, data)|
        category = category_models[category_id]
        taxon_ids = [category&.taxon&.id, category&.taxon&.parent_ids].flatten.reject(&:blank?)

        Navigation::Menu.any_in(taxon_id: taxon_ids).pluck(:id).map(&:to_s).each do |menu_id|
          memo[menu_id] ||= Hash.new(0)
          memo[menu_id][:orders] = 1

          memo[menu_id][:units_sold] += data[:units_sold]
          memo[menu_id][:discounted_units_sold] += data[:discounted_units_sold]
          memo[menu_id][:merchandise] += data[:merchandise]
          memo[menu_id][:discounts] += data[:discounts]
          memo[menu_id][:tax] += data[:tax]
          memo[menu_id][:revenue] += data[:revenue]
        end

        memo
      end
    end

    def payment
      @payment ||= Payment.find_or_initialize_by(id: order.id)
    end

    def country
      payment.address&.country&.alpha2
    end

    def shippings
      @shippings ||= Shipping.by_order(order.id)
    end

    def all_price_adjustments
      @all_price_adjustments ||= order.price_adjustments +
        shippings.map(&:price_adjustments).flatten
    end

    def discount_adjustments
      all_price_adjustments.select(&:discount?)
    end

    def discounts
      @discounts ||= begin
        price_adjustments_by_discount = discount_adjustments.group_by do |adjustment|
          adjustment.data['discount_id']
        end

        price_adjustments_by_discount.transform_values do |price_adjustments|
          {
            orders: 1,
            merchandise: sales_data[:merchandise],
            discounts: price_adjustments.map(&:amount).sum,
            revenue: sales_data[:revenue]
          }
        end
      end
    end

    def tenders
      @tenders ||= payment.tenders.each_with_object({}) do |tender, data|
        data[tender.slug] ||= { orders: 1, revenue: 0 }
        data[tender.slug][:revenue] += tender.amount
      end
    end

    def segments
      @segments ||= order.segment_ids.each_with_object({}) do |segment_id, data|
        data[segment_id] = sales_data
      end
    end

    private

    def calculate_based_on_items(items)
      result = {
        orders: 1,
        units_sold: 0,
        discounted_units_sold: 0,
        merchandise: 0,
        discounts: 0,
        tax: 0,
        revenue: 0
      }

      Array.wrap(items).reduce(result) do |memo, item|
        adjustments = PriceAdjustmentSet.new(item.price_adjustments)

        merchandise = adjustments.reject(&:discount?).sum - adjustments.adjusting('tax').sum
        discounts = adjustments.select(&:discount?).map(&:amount).sum
        tax = tax_total_for(item)

        memo[:units_sold] += item.quantity
        memo[:discounted_units_sold] += discounts < 0 ? item.quantity : 0
        memo[:merchandise] += merchandise
        memo[:discounts] += discounts
        memo[:tax] += tax
        memo[:revenue] += merchandise + discounts + tax
        memo
      end
    end

    def items_by_via
      @items_by_via ||= order.items.reduce({}) do |memo, item|
        global_id = GlobalID.parse(item.via)

        if global_id.present?
          memo[global_id] ||= Hash.new(0)
          memo[global_id][:orders] = 1

          values = calculate_based_on_items(item)
          memo[global_id][:units_sold] += values[:units_sold]
          memo[global_id][:discounted_units_sold] += values[:discounted_units_sold]
          memo[global_id][:merchandise] += values[:merchandise]
          memo[global_id][:discounts] += values[:discounts]
          memo[global_id][:tax] += values[:tax]
          memo[global_id][:revenue] += values[:revenue]
        end

        memo
      end
    end

    def tax_total_for(item)
      all_price_adjustments
        .adjusting('tax')
        .select { |a| a.data['order_item_id'].to_s == item.id.to_s }
        .sum
    end

    def category_models
      @category_models ||= Catalog::Category.any_in(id: categories.keys).to_lookup_hash
    end
  end
end
