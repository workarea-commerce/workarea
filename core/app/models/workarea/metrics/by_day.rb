module Workarea
  module Metrics
    module ByDay
      extend ActiveSupport::Concern
      include Mongoid::Document

      included do
        store_in client: :metrics

        field :reporting_on, type: Time
        index({ reporting_on: 1 }, { expire_after_seconds: 2.years.seconds.to_i })

        default_scope -> { asc(:reporting_on) }
        scope :by_date_range, ->(starts_at:, ends_at:) do
          where(
            :reporting_on.gte => starts_at.beginning_of_day,
            :reporting_on.lte => ends_at.end_of_day
          )
        end
      end

      module ClassMethods
        def inc(key: {}, at: Time.current, set: {}, **values)
          key = key.transform_values(&:to_s)
          current_id = "#{at.strftime('%Y%m%d')}-#{key.values.join('-')}".remove(/-$/)
          values = values.transform_values do |value|
            if value.is_a?(Money)
              value.exchange_to(Money.default_currency).to_f
            else
              value
            end
          end

          updates = {
            '$inc' => values,
            '$setOnInsert' => { reporting_on: at.beginning_of_day.utc }
          }

          updates.merge!('$set' => set) if set.present?
          collection.update_one(key.merge(_id: current_id), updates, upsert: true)
        end

        def today
          by_date_range(
            starts_at: Time.current.beginning_of_day,
            ends_at: Time.current.end_of_day
          ).find_or_initialize_by
        end

        def yesterday
          by_date_range(
            starts_at: 1.day.ago.beginning_of_day,
            ends_at: 1.day.ago.end_of_day
          ).find_or_initialize_by
        end
      end
    end
  end
end
