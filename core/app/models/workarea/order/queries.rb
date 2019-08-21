module Workarea
  class Order
    module Queries
      extend ActiveSupport::Concern

      included do
        scope :placed, -> { where(:placed_at.gt => Time.at(0)) }
        scope :not_placed, -> { where(placed_at: nil) }
        scope :carts, -> { where(placed_at: nil) }
        scope :recently_updated, -> { where(:updated_at.gte => 15.minutes.ago) }
        scope :since, ->(time) { where(:created_at.gte => time) }
        scope :copied_from, ->(id) { where(copied_from_id: id) }
      end

      module ClassMethods
        # Query for orders that are expired, meaning they had not
        # been updated, placed, nor completed checkout for longer than the
        # +Workarea.config.order_expiration_period+. Contrast this with
        # the +Order.expired_in_checkout+ query, which does factor in orders that
        # have entered the checkout process.
        #
        # @return [Mongoid::Criteria]
        #
        def expired
          Order.where(
            :updated_at.lt => Time.current - Workarea.config.order_expiration_period,
            checkout_started_at: nil,
            placed_at: nil
          )
        end

        # Query for orders which have expired in checkout, meaning they have been
        # not been placed or updated for longer than the
        # +Workarea.config.order_expiration_period+, but have started
        # checkout. Contrast this with +Order.expired+, which does not
        # factor in orders that have started checkout.
        #
        # @return [Mongoid::Criteria]
        def expired_in_checkout
          Order.where(
            :updated_at.lt => Time.current - Workarea.config.order_expiration_period,
            :checkout_started_at.lt => Time.current - Workarea.config.order_expiration_period,
            placed_at: nil
          )
        end

        # Find a current cart for a session. Returns a new order if one cannot be found.
        #
        # @param params [Hash]
        # @return [Order]
        #
        def find_current(params = {})
          if params[:id].present?
            Order.not_placed.find(params[:id].to_s)
          elsif params[:user_id].present?
            Order.recently_updated.not_placed.find_by(params.slice(:user_id))
          else
            Order.new(user_id: params[:user_id])
          end
        rescue Mongoid::Errors::DocumentNotFound
          Order.new(user_id: params[:user_id])
        end

        def recent(user_id, limit = 3)
          Order
            .where(user_id: user_id.to_s, :placed_at.exists => true)
            .excludes(placed_at: nil)
            .order_by([:placed_at, :desc])
            .limit(limit)
        end

        def totals(start_time = Time.current - 30.years, end_time = Time.current)
          cents = Order.
                   where(:placed_at.gte => start_time, :placed_at.lt => end_time).
                   sum('total_price.cents')

          Money.new(cents || 0)
        end

        def total_placed(start_time = Time.current - 30.years, end_time = Time.current)
          Order.
            where(:placed_at.gte => start_time, :placed_at.lt => end_time).
            count
        end

        def recent_placed(limit = 5)
          Order.
            excludes(placed_at: nil).
            order_by([:placed_at, :desc]).
            limit(limit)
        end

        def need_reminding
          Order.where(
            placed_at: nil,
            reminded_at: nil,
            :checkout_started_at.lte => Workarea.config.order_active_period.ago,
            :email.exists => true,
            :email.ne => '',
            :items.exists => true,
            :items.ne => []
          )
        end

        def find_by_token(token)
          Order.find_by(token: token) rescue nil
        end

        # Find the average order value for placed orders
        # in a given time period. This is defined as the
        # order total without taxes or shipping costs.
        #
        # @param start_time [Time, String]
        # @param end_time [Time, String]
        #
        # @return [Money]
        #
        def average_order_value(start_time = 30.years.ago, end_time = Time.current)
          cents = Order
                   .where(:placed_at.gte => start_time, :placed_at.lt => end_time)
                   .avg('total_price.cents')

          Money.new(cents || 0)
        end

        # TODO: Remove in an appropriate future version; no longer used in Base
        def abandoned_count(start_time = 30.years.ago, end_time = Time.current)
          Order
            .where(:created_at.lte => Workarea.config.order_active_period.ago)
            .where(:created_at.gte => start_time, :created_at.lt => end_time)
            .where(:'items.0.sku'.exists => true)
            .any_of({ placed_at: nil }, { :placed_at.exists => false })
            .count
        end

        # TODO: Remove in an appropriate future version; no longer used in Base
        def abandoned_value(start_time = 30.years.ago, end_time = Time.current)
          cents = Order
                    .where(:created_at.lte => Workarea.config.order_active_period.ago)
                    .where(:created_at.gte => start_time, :created_at.lt => end_time)
                    .any_of({ placed_at: nil }, { :placed_at.exists => false })
                    .sum('total_value.cents')

          Money.new(cents || 0)
        end

        # TODO: Remove in an appropriate future version; no longer used in Base
        def abandoned_product_ids(start_time = 30.years.ago, end_time = Time.current, limit = 5)
          results = Order.collection.aggregate([
            {
              '$match' => {
                 '$and' => [
                   {
                     'created_at' => {
                       '$gte' => Time.mongoize(start_time),
                       '$lt' => Time.mongoize(end_time)
                     }
                   },
                   {
                     'created_at' => { '$lte' => Time.mongoize(Workarea.config.order_active_period.ago) }
                   }
                 ],
                 '$or' => [
                   { 'placed_at' => nil },
                   { 'placed_at' => { '$exists' => false } }
                 ],
                 'items.0.sku' => { '$exists' => true }
              },
            },
            {
              '$unwind' => '$items'
            },
            {
              '$group' => {
                '_id' => '$items.product_id',
                'total' => { '$sum' => '$items.total_value.cents' },
                'count' => { '$sum' => 1 }
              }
            },
            {
              '$sort' => { 'count' => -1 }
            },
            {
              '$limit' => limit
            }
          ])

          results.reduce({}) do |memo, result|
            memo.merge!(
              result['_id'] => {
                count: result['count'],
                total: Money.new(result['total'])
              }
            )
          end
        end
      end
    end
  end
end
