/**
 * @namespace WORKAREA.styleGuideAccordions
 */
WORKAREA.registerModule('styleGuideAccordions', (function () {
    'use strict';

    var

        /**
         * @method
         * @name init
         * @memberof WORKAREA.styleGuideAccordions
         */
        init = function ($scope) {
            $('[data-style-guide-accordion]', $scope).accordion();
        };

    return {
        init: init
    };
}()));
