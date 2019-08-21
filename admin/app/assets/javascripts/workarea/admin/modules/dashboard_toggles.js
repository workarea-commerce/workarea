/**
 * Handles the display of dynamic data within a dashboard as a user toggles
 * between a given dashboard's date range.
 *
 * TODO remove in v4, not used >= 3.4
 *
 * @namespace WORKAREA.dashboardToggles
 */
WORKAREA.registerModule('dashboardToggles', (function () {
    'use strict';

    var toggleCharts = function ($dashboard, period) {
            var $chartSections = $('[data-dashboard-toggle-chart]', $dashboard);

            $chartSections.each(function (index, section) {
                var chartData = $(section).data('dashboardToggleChart')[period],
                    $chart = $('.chart__canvas', section);

                WORKAREA.dashboardCharts.update($chart, chartData);
            });
        },

        getChosenSection = function ($allSections, chosenPeriod) {
            return $allSections.filter(function (index, section) {
                var period = $(section).data('dashboardToggleSection');
                return period === chosenPeriod;
            });
        },

        toggleSections = function ($dashboard, period) {
            var $allSections = $('[data-dashboard-toggle-section]', $dashboard),
                $sectionsForPeriod = getChosenSection($allSections, period);

            $allSections.addClass('hidden');
            $sectionsForPeriod.removeClass('hidden');
        },

        updateDashboard = function (event) {
            var $dashboard = $(event.delegateTarget),
                period = event.currentTarget.value;

            toggleSections($dashboard, period);
            toggleCharts($dashboard, period);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.dashboardToggles
         */
        init = function ($scope) {
            $('.dashboard__card', $scope)
            .on('change', '[data-dashboard-toggle]', updateDashboard);
        };

    return {
        init: init
    };
}()));
