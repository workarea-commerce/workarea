/**
 * Responsible for the display of a Dashboard's Charts
 *
 * TODO remove in v4, not used >= 3.4
 *
 * @namespace WORKAREA.dashboardCharts
 */
WORKAREA.registerModule('dashboardCharts', (function () {
    'use strict';

    var legendTemplate = JST['workarea/admin/templates/chart_legend'],

        findAssociatedLegend = function (name, index, container) {
            return name === $(container).data('dashboardChartLegend');
        },

        removeLegend = function ($chart, options) {
            $chart
                .closest('.dashboard__card')
                    .find('[data-dashboard-chart-legend]')
                        .filter(_.partial(findAssociatedLegend, options.name))
                        .empty();
        },

        addLegend = function (chart, options, data) {
            var datasets;

            if (options.type === 'Doughnut') {
                datasets = data;
            } else {
                datasets = data.datasets;
            }

            $(chart.chart.canvas)
                .closest('.dashboard__card')
                    .find('[data-dashboard-chart-legend]')
                        .filter(_.partial(findAssociatedLegend, options.name))
                        .append(legendTemplate({ datasets: datasets }));
        },

        applyBarChartSpacing = function (config, options) {
            return _.merge(config, {
                barValueSpacing: options.barChartSpacing[0],
                barDatasetSpacing: options.barChartSpacing[1]
            });
        },

        getColorIndex = function (options, palette, index) {
            var colorIndexOffset = options.offsetColorsBy || 0;

            index += colorIndexOffset;

            return (index >= palette.length) ? index - palette.length : index;
        },

        colorChartData = function (options) {
            var palette = WORKAREA.config.dashboardCharts.colors,
                data = options.chartData;

            if (_.includes(['Bar', 'HorizontalBar'], options.type)) {
                data.datasets = _.map(data.datasets, function (dataset, index) {
                    index = getColorIndex(options, palette, index);

                    return _.merge(dataset, {
                        fillColor: 'rgba(' + palette[index] + ', 1)',
                        strokeColor: 'rgba(255, 255, 255, 1)',
                        highlightFill: 'rgba(' + palette[index] + ', 1)',
                        highlightStroke: 'rgba(255, 255, 255, 1)',
                        legendColor: 'rgba(' + palette[index] + ', 1)'
                    });
                });
            } else if (options.type === 'Line') {
                data.datasets = _.map(data.datasets, function (dataset, index) {
                    index = getColorIndex(options, palette, index);

                    return _.merge(dataset, {
                        strokeColor: 'rgba(' + palette[index] + ', 1)',
                        pointColor: 'rgba(' + palette[index] + ', 1)',
                        legendColor: 'rgba(' + palette[index] + ', 1)'
                    });
                });
            } else if (options.type === 'Doughnut') {
                data = _.map(data, function (dataset, index) {
                    index = getColorIndex(options, palette, index);

                    return _.merge(dataset, {
                        color: 'rgba(' + palette[index] + ', 1)',
                        highlight: 'rgba(' + palette[index] + ', 0.75)',
                        legendColor: 'rgba(' + palette[index] + ', 1)'
                    });
                });
            }

            return data;
        },

        initChart = function (index, canvas) {
            var options = $(canvas).data('dashboardChart'),
                context, chart, data, config;

            if (_.isUndefined(options.chartData)) {
                throw new Error(
                    'WORKAREA.dashboardCharts.initChart: you must supply a ' +
                    'data object as the value for `chartData`.'
                );
            }

            // do not continue if no chart data exists to render
            if (_.isPlainObject(options.chartData) && _.isEmpty(options.chartData.labels)) {
                return;
            }

            context = canvas.getContext('2d');
            chart = new Chart(context);
            data = colorChartData(options);

            config = WORKAREA.config.dashboardCharts.types[options.type];

            if ( ! _.isUndefined(options.barChartSpacing)) {
                config = applyBarChartSpacing(config, options);
            }

            chart = chart[options.type](data, config);

            $(canvas).data('chartInstance', chart);

            if (_.isUndefined(options.name)) { return; }

            addLegend(chart, options, data);
        },

        /**
         * Destroys and re-instantiates the given `$chart` with new `chartData`
         *
         * @method
         * @name update
         * @memberof WORKAREA.dashboardCharts
         * @param {jQuery} $chart - the chart's canvas element
         * @param {Object} chartData - the new data to update the chart with
         */

        update = function ($chart, chartData) {
            var chartInstance = $chart.data('chartInstance'),
                options = $chart.data('dashboardChart');

            if (_.isUndefined(chartInstance)) { return; }

            options.chartData = chartData;
            $chart.data('dashboardChart', options);

            chartInstance.destroy();

            removeLegend($chart, options);

            initChart(null, $chart[0]);
        },

        /**
         * Module behavior can be augmented by supplying a JSON object as the
         * value of `[data-dashboard-chart]`:
         *
         * {
         *     "type": {String} - type of chart, CamelCased
         *     "chartData": {Object} - contains datasets to chart
         *     "offsetColorsBy": {Integer} - offset the color array (optional)
         *     "barChartSpacing": {Array} - update bar spacing values (optional)
         *     "name": {String} - associates chart to legend (optional)
         *  }
         *
         * @method
         * @name init
         * @memberof WORKAREA.dashboardCharts
         */
        init = function ($scope) {
            $('[data-dashboard-chart]', $scope).each(initChart);
        };

    return {
        init: init,
        update: update
    };
}()));
