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

        transformReleaseDataset = function (dataset) {
            return _.chain(dataset)
                    .filter(function (data) {
                        return data.y > 0;
                    })
                    .map(function (data) {
                        return { x: data.x, y: 0, count: data.y };
                    })
                    .value();
        },

        transformDataset = function (dataset) {
            return _.map(dataset, function (data) {
                return { x: new Date(data.x), y: data.y };
            });
        },

        buildDatasets = function (datasets) {
            return _.map(datasets, function (dataset, key) {
                var config = WORKAREA.config.timelineReportChart.datasets,
                    color = WORKAREA.config.timelineReportChart.colors[key],
                    dataConfig = _.merge({}, config, {
                        label: I18n.t('workarea.admin.reports.timeline.' + key),
                        borderColor: color,
                        backgroundColor: color,
                    }),
                    data = transformDataset(dataset);

                if (key === 'revenue') {
                    dataConfig.yAxisID = 'money-axis';
                } else {
                    dataConfig.yAxisID = 'unit-axis';
                }

                if (key === 'releases') {
                    dataConfig.data = transformReleaseDataset(data);
                    dataConfig.pointStyle = 'triangle';
                    dataConfig.radius = 10;
                    dataConfig.hoverRadius = 13;
                } else {
                    dataConfig.data = data;
                }

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
