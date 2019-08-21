module Workarea
  module Storefront
    class AnalyticsController < ActionController::Metal
      include ActionController::Instrumentation

      def category_view
        unless robot?
          Metrics::CategoryByDay.inc(key: { category_id: params[:category_id] }, views: 1)
        end
      end

      def product_view
        unless robot?
          Metrics::ProductByDay.inc(key: { product_id: params[:product_id] }, views: 1)
        end
      end

      def search
        unless robot?
          Metrics::SearchByDay.save_search(params[:q], params[:total_results])
        end
      end

      def search_abandonment
      warn <<~eos
DEPRECATION WARNING: Search abandonment tracking is deprecated and will be removed \
in Workarea 3.5.
      eos
      end

      def filters
      warn <<~eos
DEPRECATION WARNING: Filter analytics tracking is deprecated and will be removed \
in Workarea 3.5.
      eos
      end

      private

      def robot?
        Robots.is_robot?(request.user_agent)
      end
    end
  end
end
