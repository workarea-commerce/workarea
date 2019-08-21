module Workarea
  module Reports
    module Report
      extend ActiveSupport::Concern

      included do
        attr_reader :params
        cattr_accessor :reporting_class, :sort_fields, :sort_directions

        self.sort_directions = %w(desc asc)
      end

      def initialize(params = {})
        @params = params.to_h.with_indifferent_access
      end

      def slug
        self.class.name.demodulize.underscore
      end

      def starts_at
        @starts_at ||= begin
          default = Workarea.config.reports_default_starts_at.call
          value = Time.zone.parse(params[:starts_at].to_s) || default rescue default
          value.beginning_of_day
        end
      end

      def ends_at
        @ends_at ||= begin
          value = Time.zone.parse(params[:ends_at].to_s) || Time.current rescue Time.current
          value.end_of_day
        end
      end

      def sort
        { '$sort' => sort_value }
      end

      def limit
        { '$limit' => Workarea.config.reports_max_results }
      end

      def sort_by
        @sort_by ||= params[:sort_by].presence_in(sort_fields) || sort_fields.first
      end

      def sort_value
        { sort_by => sort_direction == 'desc' ? -1 : 1 }
      end

      def sort_direction
        @sort_direction ||= params[:sort_direction].presence_in(sort_directions) ||
          sort_directions.first
      end

      def count
        results.length
      end

      def more_results?
        count >= Workarea.config.reports_max_results
      end

      def results
        @results ||= Rails.cache.fetch(cache_key, expires_in: Workarea.config.cache_expirations.reports) do
          reporting_class.collection.aggregate(aggregation + [sort, limit]).to_a
        end
      end

      def cache_key
        cache_params = params.reject { |k, v| k.blank? || v.blank? }.sort

        [
          :reports,
          slug,
          Time.current.strftime('%Y%m%d'),
          Digest::SHA1.hexdigest(cache_params.to_s)
        ].join('/')
      end
    end
  end
end
