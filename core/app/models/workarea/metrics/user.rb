module Workarea
  module Metrics
    class User
      include Mongoid::Document

      store_in client: :metrics

      # _id will be the customer's email address
      field :_id, type: String, default: -> { BSON::ObjectId.new.to_s }
      field :first_order_at, type: Time
      field :last_order_at, type: Time
      field :orders, type: Integer, default: 0
      field :revenue, type: Float, default: 0.0
      field :discounts, type: Float, default: 0.0
      field :frequency, type: Float, default: 0.0
      field :average_order_value, type: Float, default: 0.0
      field :orders_percentile, type: Integer, default: 10
      field :revenue_percentile, type: Integer, default: 10
      field :frequency_percentile, type: Integer, default: 10
      field :average_order_value_percentile, type: Integer, default: 10

      index(first_order_at: 1)
      index(last_order_at: 1)
      index(orders: 1)
      index(revenue: 1)
      index(frequency: 1)
      index(average_order_value: 1)

      scope :with_purchases, -> { where(:orders.gt => 0, :revenue.gt => 0) }
      scope :ordered_since, ->(time) { where(:last_order_at.gte => time) }
      scope :by_orders_percentile, ->(range) { where(orders_percentile: range) }
      scope :by_frequency_percentile, ->(range) { where(frequency_percentile: range) }
      scope :by_revenue_percentile, ->(range) { where(revenue_percentile: range) }
      scope :by_average_order_value_percentile, ->(range) { where(average_order_value_percentile: range) }
      scope :full_price, -> { where(discounts: 0) }

      class << self
        def save_order(email:, revenue:, discounts: 0, at: Time.current)
          revenue_in_default_currency = revenue.to_m.exchange_to(Money.default_currency).to_f
          discounts_in_default_currency = discounts.to_m.exchange_to(Money.default_currency).to_f

          collection.update_one(
            { _id: email },
            {
              '$set' => { last_order_at: at.utc },
              '$setOnInsert' => { first_order_at: at.utc },
              '$inc' => {
                orders: 1,
                revenue: revenue_in_default_currency,
                discounts: discounts_in_default_currency
              }
            },
            upsert: true
          )
        end

        def best
          scoped
            .with_purchases
            .by_frequency_percentile(81..100)
            .by_revenue_percentile(81..100)
            .order_by(revenue: :desc, orders: :desc, last_order_at: :desc, id: :asc)
        end

        def update_aggregations!
          update_calculated_fields!
          update_percentiles!
        end

        def update_calculated_fields!
          collection.aggregate([
            {
              '$addFields' => {
                'frequency' => {
                  '$divide' => [
                    '$orders',
                    { '$subtract' => [Time.current, '$first_order_at'] }
                  ]
                },
                'average_order_value' => {
                  '$divide' => ['$revenue', '$orders']
                }
              }
            },
            { '$out' => collection.name }
          ]).first
        end

        def update_percentiles!
          collection.aggregate([
            {
              '$addFields' => {
                'orders_percentile' => update_percentiles_expression(:orders),
                'frequency_percentile' => update_percentiles_expression(:frequency),
                'revenue_percentile' => update_percentiles_expression(:revenue),
                'average_order_value_percentile' => update_percentiles_expression(:average_order_value)
              }
            },
            { '$out' => collection.name }
          ]).first
        end

        def update_percentiles_expression(field)
          percentiles = CalculatePercentiles.new(collection, field)

          {
            '$switch' => {
              'branches' => 99.downto(1).map do |percentile|
                {
                  'case' => {  '$gte' => ["$#{field}", percentiles[percentile.to_s]] },
                  'then' => percentile + 1
                }
              end,
              'default' => 1
            }
          }
        end
      end

      # Use calculated value for real-time display, the aggregated value used
      # in insights we be recalculated weekly.
      def average_order_value
        return nil if orders.zero?
        revenue / orders.to_f
      end
    end
  end
end
