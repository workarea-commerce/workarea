module Workarea
  module Admin
    module DateSelectorHelper
      def date_selector_quick_range_options
        [
          [t('workarea.admin.date_selector.a_range')],
          [t('workarea.admin.date_selector.today'), Date.current.strftime('%F')],
          [
            t('workarea.admin.date_selector.yesterday'),
            1.day.ago.strftime('%F')
          ],
          [
            t('workarea.admin.date_selector.last_week'),
            [
              1.week.ago.beginning_of_week.strftime('%F'),
              1.week.ago.end_of_week.strftime('%F')
            ].join('|')
          ],
          [
            t('workarea.admin.date_selector.last_month'),
            [
              1.month.ago.beginning_of_month.strftime('%F'),
              1.month.ago.end_of_month.strftime('%F')
            ].join('|')
          ],
          [
            t('workarea.admin.date_selector.week_to_date'),
            [
              Date.current.beginning_of_week.strftime('%F'),
              Date.current.strftime('%F')
            ].join('|')
          ],
          [
            t('workarea.admin.date_selector.month_to_date'),
            [
              Date.current.beginning_of_month.strftime('%F'),
              Date.current.strftime('%F')
            ].join('|')
          ],
          [
            t('workarea.admin.date_selector.quarter_to_date'),
            [
              Date.current.beginning_of_quarter.strftime('%F'),
              Date.current.strftime('%F')
            ].join('|')
          ],
          [
            t('workarea.admin.date_selector.year_to_date'),
            [
              Date.current.beginning_of_year.strftime('%F'),
              Date.current.strftime('%F')
            ].join('|')
          ]
        ]
      end
    end
  end
end
