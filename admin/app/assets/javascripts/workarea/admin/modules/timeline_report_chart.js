/**
 * @namespace WORKAREA.timelineReportChart
 */
WORKAREA.registerModule('timelineReportChart', (function () {
    'use strict';

    var updateChart = function (chart, event) {
            var $item = $(event.target).closest('.chart-legend__list-item'),
                dataset = chart.data.datasets[event.target.value];

            if (event.target.checked) {
                dataset.hidden = false;
                $item.removeClass('chart-legend__list-item--disabled');
            } else {
                dataset.hidden = true;
                $item.addClass('chart-legend__list-item--disabled');
            }

            chart.update();
        },

        setupLegend = function (chart) {
            var legend = JST['workarea/admin/templates/chart_legend']({
                datasets: chart.data.datasets,
                enabled: WORKAREA.config.timelineReportChart.initiallyActive
            });

            $('#timeline-report-chart-legend')
            .html(legend)
            .on('change', '[type=checkbox]', _.partial(updateChart, chart))
                .find('[type=checkbox]')
                .trigger('change');
        },

        transformDataset = function (dataset, type) {
            return _.map(dataset, function (item) {
                var data = { x: new Date(item.x) };

                if (type === 'releases') {
                    data.y = item.y > 0 ? 0 : null;
                    data.releaseCount = item.y;
                } else {
                    data.y = item.y || 0;
                }

                return data;
            });
        },

        buildDatasets = function (datasets) {
            return _.map(datasets, function (dataset, type) {
                var config = WORKAREA.config.timelineReportChart.datasets,
                    color = WORKAREA.config.timelineReportChart.colors[type],
                    dataConfig = _.merge({}, config, {
                        label: I18n.t('workarea.admin.reports.timeline.' + type),
                        borderColor: color,
                        backgroundColor: color,
                    });

                if (type === 'revenue') {
                    dataConfig.yAxisID = 'money-axis';
                } else {
                    dataConfig.yAxisID = 'unit-axis';
                }

                if (type === 'releases') {
                    dataConfig.pointStyle = 'triangle';
                    dataConfig.radius = 10;
                    dataConfig.hoverRadius = 13;
                }

                dataConfig.data = transformDataset(dataset, type);

                return dataConfig;
            });
        },

        getConfig = function (data) {
            return {
                type: 'line',
                data: {
                    labels: _.map(data.labels, function (value) {
                        return new Date(value);
                    }),
                    datasets: buildDatasets(data.datasets)
                },
                options: WORKAREA.config.timelineReportChart.options
            };
        },

        setup = function (index, canvas) {
            var data = $(canvas).data('timelineReportChart'),
                chart = new Chart(canvas.getContext('2d'), getConfig(data));

            setupLegend(chart);
        },

        init = function ($scope) {
            $('[data-timeline-report-chart]', $scope).each(setup);
        };

    return {
        init: init
    };
}()));
