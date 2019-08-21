/**
 * @namespace WORKAREA.styleGuideEmptyLinks
 */
WORKAREA.registerModule('styleGuideEmptyLinks', (function () {
    'use strict';

    var stopAction = function (event) {
            event.preventDefault();
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.styleGuideEmptyLinks
         */
        init = function ($scope) {
            $('.style-guide a[href="#"]', $scope).on('click', stopAction);
        };

    return {
        init: init
    };
}()));
