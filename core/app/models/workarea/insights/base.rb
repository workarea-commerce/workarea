module Workarea
  module Insights
    class Base
      include ApplicationDocument

      field :results, type: Array, default: []
      field :reporting_on, type: Time, default: -> { Time.current.yesterday }
      field :dashboards, type: Array, default: -> { self.class.dashboards }

      index(_type: 1)
      index(dashboards: 1)
      index({ created_at: 1 }, { expire_after_seconds: 2.years.seconds.to_i })

      default_scope -> { desc(:created_at) }
      scope :by_dashboard, ->(*dashboards) { any_in(dashboards: dashboards) }
      scope :by_product, ->(id) { where('results.product_id': id) }
      scope :by_category, ->(id) { where('results.category_id': id) }
      scope :by_customer, ->(id) { where('results._id': id) }
      scope :by_discount, ->(id) { where('results.discount_id': id) }
      scope :by_search, ->(id) { where('results.query_id': id) }

      class << self
        def generate_daily!
          # allow subclasses to implement daily insight generation
        end

        def generate_weekly!
          # allow subclasses to implement weekly insight generation
        end

        def generate_monthly!
          # allow subclasses to implement monthly insight generation
        end

        def current
          desc(:created_at).first || new
        end

        # Allow subclasses to specify on which dashboards they show
        def dashboards
          []
        end

        def beginning_of_last_month
          Time.current.last_month.beginning_of_month
        end

        def end_of_last_month
          Time.current.last_month.end_of_month
        end
      end

      def slug
        self.class.name.demodulize.underscore
      end

      def include?(test)
        test_typecasted = test.transform_keys(&:to_s).transform_values(&:to_s)
        results.any? do |result|
          result_typecasted = result.transform_keys(&:to_s).transform_values(&:to_s)
          (test_typecasted.to_a - result_typecasted.to_a).empty?
        end
      end
    end
  end
end
