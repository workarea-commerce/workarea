module Workarea
  module Metrics
    class User
      include Mongoid::Document
      include Mongoid::Document::Taggable
      include Mongoid::Timestamps

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
      field :cancellations, type: Integer, default: 0
      field :refund, type: Float, default: 0.0

      index(first_order_at: 1)
      index(last_order_at: 1)
      index(orders: 1)
      index(revenue: 1)
      index(frequency: 1)
      index(average_order_value: 1)
      index(updated_at: 1)

      scope :with_purchases, -> { where(:orders.gt => 0, :revenue.gt => 0) }
      scope :ordered_since, ->(time) { where(:last_order_at.gte => time) }
      scope :by_orders_percentile, ->(range) { where(orders_percentile: range) }
      scope :by_frequency_percentile, ->(range) { where(frequency_percentile: range) }
      scope :by_revenue_percentile, ->(range) { where(revenue_percentile: range) }
      scope :by_average_order_value_percentile, ->(range) { where(average_order_value_percentile: range) }
      scope :full_price, -> { where(discounts: 0) }

      embeds_one :viewed, class_name: 'Workarea::Metrics::Affinity', inverse_of: :user, autobuild: true
      embeds_one :purchased, class_name: 'Workarea::Metrics::Affinity', inverse_of: :user, autobuild: true

      class << self
        def save_order(email:, revenue:, discounts: 0, at: Time.current)
          revenue_in_default_currency = revenue.to_m.exchange_to(Money.default_currency).to_f
          discounts_in_default_currency = discounts.to_m.exchange_to(Money.default_currency).to_f

          metrics = find_or_create_by(id: email)
          first_order_at = [at, metrics.first_order_at].compact.min
          last_order_at = [at, metrics.last_order_at].compact.max

          metrics.update!(first_order_at: first_order_at, last_order_at: last_order_at)
          metrics.inc(
            orders: 1,
            revenue: revenue_in_default_currency,
            discounts: discounts_in_default_currency
          )
        end

        def save_cancellation(email:, refund:, at: Time.current)
          refund_in_default_currency = refund.to_m.exchange_to(Money.default_currency).to_f

          collection.update_one(
            { _id: email },
            {
              '$inc' => {
                cancellations: 1,
                refund: refund_in_default_currency,
                revenue: refund_in_default_currency
              }
            }
          )
        end

        def save_affinity(id:, action:, **data)
          return if data.blank? || data.values.all?(&:blank?)

          collection.update_one(
            { _id: id },
            {
              '$set' => { updated_at: Time.current.utc },
              '$addToSet' => data.each_with_object({}) do |(field, values), update|
                update["#{action}.#{field}"] = { '$each' => Array.wrap(values) }
              end
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
      end

      # Use calculated value for real-time display, the aggregated value used
      # in insights we be recalculated weekly.
      def average_order_value
        return nil if orders.zero?
        revenue / orders.to_f
      end

      def merge!(other)
        %w(orders revenue discounts cancellations refund).each do |field|
          self.send("#{field}=", send(field) + other.send(field))
        end

        self.first_order_at = [first_order_at, other.first_order_at].compact.min
        self.last_order_at = [last_order_at, other.last_order_at].compact.max
        self.average_order_value = average_order_value
        save!

        self.class.save_affinity(
          id: id,
          action: 'viewed',
          product_ids: other.viewed.product_ids,
          category_ids: other.viewed.category_ids,
          search_ids: other.viewed.search_ids
        )
        self.class.save_affinity(
          id: id,
          action: 'purchased',
          product_ids: other.purchased.product_ids,
          category_ids: other.purchased.category_ids,
          search_ids: other.purchased.search_ids
        )
      end
    end
  end
end
