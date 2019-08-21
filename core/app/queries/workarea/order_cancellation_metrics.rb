module Workarea
  class OrderCancellationMetrics
    attr_reader :order, :occured_at
    delegate_missing_to :order

    def initialize(order, item_values: {}, shipping_value: nil, occured_at: Time.current)
      @order = order
      @item_values = item_values
      @shipping_value = shipping_value
      @occured_at = occured_at&.to_time
    end

    def sales_data
      @sales_data ||= begin
        based_on_items = calculate_based_on_items(items)
        refund = based_on_items[:refund] + shipping_refund_total
        {
          cancellations: 1,
          units_canceled: based_on_items[:units_canceled],
          refund: refund,
          revenue: refund
        }
      end
    end

    def user_data
      {
        email: email,
        refund: sales_data[:refund]
      }
    end

    def products
      @products ||= order.items
         .group_by(&:product_id)
         .transform_values { |items| calculate_based_on_items(items) }
         .reject { |_, v| v.blank? }
    end

    def categories
      @categories ||= items_by_via
        .select { |gid| gid.model_class.name == 'Workarea::Catalog::Category' }
        .transform_keys(&:model_id)
    end

    def searches
      @searches ||= items_by_via
        .select { |gid| gid.model_class.name == 'Workarea::Navigation::SearchResults' }
        .each_with_object({}) do |(gid, data), memo|
          query_id = gid.find.query_string.id

          memo[query_id] ||= Hash.new(0)
          memo[query_id].merge!(data) { |_, total, current| total + current }
        end
    end

    def skus
      @skus ||= order.items
        .group_by(&:sku)
        .transform_values { |items| calculate_based_on_items(items) }
        .reject { |_, v| v.blank? }
    end

    def menus
      @menus ||= categories.each_with_object({}) do |(category_id, data), memo|
        category = category_models[category_id]
        taxon_ids = [category&.taxon&.id, *category&.taxon&.parent_ids].compact

        Navigation::Menu.any_in(taxon_id: taxon_ids).pluck(:id).map(&:to_s).each do |menu_id|
          memo[menu_id] ||= Hash.new(0)
          memo[menu_id].merge!(data) { |_, total, current| total + current }
        end

        memo
      end.reject { |_, v| v.blank? }
    end

    def country
      payment.address&.country&.alpha2
    end

    def shipping_refund_total
      (@shipping_value || shipping_total || 0) * -1
    end

    def segments
      @segments ||= order.segment_ids.each_with_object({}) do |segment_id, data|
        data[segment_id] = sales_data
      end
    end

    private

    def payment
      @payment ||= Payment.find_or_initialize_by(id: order.id)
    end

    def shippings
      @shippings ||= Shipping.by_order(order.id)
    end

    def all_price_adjustments
      @all_price_adjustments ||= order.price_adjustments +
        shippings.map(&:price_adjustments).flatten
    end

    def calculate_based_on_items(items)
      Array.wrap(items).each_with_object(Hash.new(0)) do |item, memo|
        data = item_data[item.id.to_s]&.with_indifferent_access
        next unless data.present?

        memo[:units_canceled] += data[:quantity]
        memo[:refund] += data[:amount] * -1
        memo[:revenue] += data[:amount] * -1
      end
    end

    def item_data
      return @item_values if @item_values.present?

      @item_data ||= items.each_with_object({}) do |item, data|
        adjustments = PriceAdjustmentSet.new(item.price_adjustments)
        before_tax = adjustments.sum - adjustments.adjusting('tax').sum

        data[item.id.to_s] = {
          quantity: item.quantity,
          amount: before_tax + tax_total_for(item.id)
        }
      end
    end

    def items_by_via
      @items_by_via ||= order.items.each_with_object({}) do |item, memo|
        global_id = GlobalID.parse(item.via)
        next unless global_id.present?

        memo[global_id] ||= Hash.new(0)
        values = calculate_based_on_items(item)

        memo[global_id].merge!(values) { |_, sum, item| sum + item }
      end.reject { |_, v| v.blank? }
    end

    def tax_total_for(item_id)
      all_price_adjustments
        .adjusting('tax')
        .select { |a| a.data['order_item_id'].to_s == item_id.to_s }
        .sum
    end

    def category_models
      @category_models ||= Catalog::Category.any_in(id: categories.keys).to_lookup_hash
    end
  end
end
