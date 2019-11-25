/**
 * @namespace WORKAREA.timelineReportChart
 */
WORKAREA.registerModule('timelineReportChart', (function () {
    'use strict';

    var updateChart = function (chart, event) {
            var $item = $(event.target).closest('.chart-legend__list-item'),
                dataset = chart.data.datasets[event.target.value];

            if ($item.is('.chart-legend__list-item--no-interact')) {
                event.preventDefault();
                event.stopPropagation();
                return;
            }

            if (event.target.checked) {
                dataset.hidden = false;
                $item.removeClass('chart-legend__list-item--disabled');
            } else {
                dataset.hidden = true;
                $item.addClass('chart-legend__list-item--disabled');
            }

            chart.update();
        },

        closeTooltip = function (chart) {
            chart.tooltip._active = [];
        },

        showTooltip = function (chart, indiciesGroup) {
            var activeElements = chart.tooltip._active || [];

            _.forEach(indiciesGroup, function (indicies) {
                activeElements.push(
                    chart.getDatasetMeta(indicies[0]).data[indicies[1]]
                );
            });

            chart.tooltip._active = activeElements;
        },

        toggleTooltip = function (toggle, chart, event) {
            var $target = $(event.currentTarget),
                dateChunks = $target.data('timelineReportChartEvent'),
                date = new Date(dateChunks[0], dateChunks[1] - 1, dateChunks[2]),
                indiciesGroup = [];

            _.forEach(chart.data.datasets, function (dataset, datasetIndex) {
                _.forEach(dataset.data, function (data, pointIndex) {
                    if (data.x.getTime() === date.getTime()) {
                        indiciesGroup.push([datasetIndex, pointIndex]);
                    }
                });
            });

            if (toggle === 'open') {
                showTooltip(chart, indiciesGroup);
            } else if (toggle === 'close') {
                closeTooltip(chart);
            }

            chart.tooltip.update(true);
            chart.draw();
        },

        setupSidebar = function (chart) {
            $(chart.canvas)
                .closest('.view')
                    .find('[data-timeline-report-chart-event]')
                    .on('mouseenter', _.partial(toggleTooltip, 'open', chart))
                    .on('mouseleave', _.partial(toggleTooltip, 'close', chart));
        },

        setupLegend = function (chart) {
            var legend = JST['workarea/admin/templates/chart_legend']({
                datasets: chart.data.datasets,
                enabled: WORKAREA.config.timelineReportChart.initiallyActive,
                noInteract: ['Releases', 'Custom Events']
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

                if (type === 'releases' || type === 'custom_events') {
                    data.y = item.y > 0 ? 0 : null;
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

                if (_.includes(['releases', 'custom_events'], type)) {
                    dataConfig.radius = 10;
                    dataConfig.hoverRadius = 13;
                    dataConfig.showLine = false;
                    dataConfig.pointStyle = 'triangle';
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
            setupSidebar(chart);
        },

        destroyEventTooltips = function () {
            $('[data-tooltip]').each(function (_, trigger) {
                $(trigger).tooltipster('destroy');
            });
        },

        init = function ($scope) {
            $('[data-timeline-report-chart]', $scope).each(setup);
        };

    $(document).on('turbolinks:before-cache', destroyEventTooltips);

    return {
        init: init
    };
}()));
