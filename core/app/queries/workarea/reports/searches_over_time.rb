module Workarea
  module Reports
    class SearchesOverTime
      include Report
      include GroupByTime

      self.reporting_class = Metrics::SearchByDay
      self.sort_fields = %w(_id searches)

      def aggregation
        [filter_date_range, project_used_fields, group_by_time]
      end

      def filter_date_range
        {
          '$match' => {
            'reporting_on' => { '$gte' => starts_at.utc, '$lte' => ends_at.utc }
          }
        }
      end

      def project_used_fields
        { '$project' => { 'reporting_on' => 1, 'searches' => 1 } }
      end

      def group_by_time
        {
          '$group' => {
            '_id' => time_group_id,
            'starts_at' => { '$min' => '$reporting_on' },
            'searches' => { '$sum' => '$searches' }
          }
        }
      end
    end
  end
end
