module Workarea
  module Storefront
    class AnalyticsController < Storefront::ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :ignore_bots

      def new_session
        Metrics::SalesByDay.inc(sessions: 1)

        current_segments.each do |segment|
          Metrics::SegmentByDay.inc(key: { segment_id: segment.id }, sessions: 1)
        end
      end

      def category_view
        if params[:category_id].present?
          Metrics::CategoryByDay.inc(key: { category_id: params[:category_id] }, views: 1)
          Metrics::User.save_affinity(
            id: current_metrics_id,
            action: 'viewed',
            category_ids: params[:category_id]
          )
        end
      end

      def product_view
        if params[:product_id].present?
          Metrics::ProductByDay.inc(key: { product_id: params[:product_id] }, views: 1)
          Metrics::User.save_affinity(
            id: current_metrics_id,
            action: 'viewed',
            product_ids: params[:product_id]
          )
        end
      end

      def search
        query_string = QueryString.new(params[:q])

        if query_string.present? && !query_string.short?
          Metrics::SearchByDay.save_search(params[:q], params[:total_results])
          Metrics::User.save_affinity(
            id: current_metrics_id,
            action: 'viewed',
            search_ids: query_string.id
          )
        end
      end

      private

      def ignore_bots
        if browser.bot.bot? || browser.bot.search_engine?
          head(:forbidden)
          return false
        end
      end
    end
  end
end
