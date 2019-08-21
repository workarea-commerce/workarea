/**
 * @namespace WORKAREA.recommendationsSortables
 */
WORKAREA.registerModule('recommendationsSortables', (function () {
    'use strict';

    /**
     * @method
     * @name init
     * @memberof WORKAREA.recommendationsSortables
     */
    var init = function ($scope) {
            $('[data-recommendations-sortable]', $scope)
            .sortable(WORKAREA.config.recommendationsSortables);
        };

    return {
        init: init
    };
}()));
