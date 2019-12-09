module Workarea
  module Reports
    module GroupByTime
      extend ActiveSupport::Concern

      included do
        cattr_accessor :group_bys
        self.group_bys = %w(year quarter month week day day_of_week)
      end

      def time_group_id
        case group_by
        when 'year' then year_id
        when 'quarter' then quarter_id
        when 'week' then week_id
        when 'day_of_week' then day_of_week_id
        when 'day' then day_id
        else month_id
        end
      end

      def group_by
        @group_by ||= params[:group_by].presence_in(group_bys) || 'month'
      end

      private

      def reporting_on_in_time_zone
        { 'date' => '$reporting_on', 'timezone' => Time.zone.tzinfo.name }
      end

      def day_id
        {
          'year' => { '$year' => reporting_on_in_time_zone },
          'month' => { '$month' => reporting_on_in_time_zone },
          'day' => { '$dayOfMonth' => reporting_on_in_time_zone }
        }
      end

      def week_id
        {
          'year' => { '$year' => reporting_on_in_time_zone },
          'week' => { '$isoWeek' => reporting_on_in_time_zone }
        }
      end

      def day_of_week_id
        { 'day_of_week' => { '$dayOfWeek' => reporting_on_in_time_zone } }
      end

      def month_id
        {
          'year' => { '$year' => reporting_on_in_time_zone },
          'month' => { '$month' => reporting_on_in_time_zone }
        }
      end

      def quarter_id
        {
          'year' => { '$year' => reporting_on_in_time_zone },
          'quarter' => {
            '$cond' => [
              { '$lte' => [{ '$month' => reporting_on_in_time_zone }, 3] },
              1,
              {
                '$cond' => [
                  { '$lte' => [{ '$month' => reporting_on_in_time_zone }, 6] },
                  2,
                  {
                    '$cond' => [
                      { '$lte' => [{ '$month' => reporting_on_in_time_zone }, 9] },
                      3,
                      4
                    ]
                  }
                ]
              }
            ]
          }
        }
      end

      def year_id
        { 'year' => { '$year' => reporting_on_in_time_zone } }
      end
    end
  end
end
