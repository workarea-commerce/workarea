module Workarea
  module Admin
    module ReportsHelper
      def render_reports_results_message(report)
        if report.more_results?
          t(
            'workarea.admin.reports.partial_results_html',
            count: report.count,
            export_link: link_to(
              t('workarea.admin.reports.export_results').downcase,
              '#export-results',
              data: { tooltip: { interactive: true, side: 'bottom' } }
            )
          )
        else
          t(
            'workarea.admin.reports.full_results_html',
            count: report.count,
            export_link: link_to(
              t('workarea.admin.reports.export_results'),
              '#export-results',
              data: { tooltip: { interactive: true, side: 'bottom' } }
            )
          )
        end
      end

      def link_to_reports_sorting(name, report:, sort_by:)
        direction = if report.sort_by == sort_by
          report.sort_direction == 'desc' ? 'asc' : 'desc'
        else
          :desc
        end

        icons = { 'desc' => '↓', 'asc' => '↑' }
        icon = report.sort_by == sort_by ? icons[report.sort_direction] : ''
        link_to "#{name} #{icon}".strip, params.merge(sort_by: sort_by, sort_direction: direction)
      end

      def searches_report_filter_options
        [
          [t('workarea.admin.reports.searches.filters.all'), nil],
          [t('workarea.admin.reports.searches.filters.with_results'), 'with_results'],
          [t('workarea.admin.reports.searches.filters.without_results'), 'without_results']
        ]
      end

      def customers_report_filter_options
        [
          [t('workarea.admin.reports.customers.filters.all'), nil],
          [t('workarea.admin.reports.customers.filters.one_time'), 'one_time'],
          [t('workarea.admin.reports.customers.filters.returning'), 'returning']
        ]
      end
    end
  end
end
