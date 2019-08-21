/**
 * @namespace WORKAREA.recentViews
 */
WORKAREA.registerModule('recentViews', (function () {
    'use strict';

    var updateRecentViews = function (index, element) {
            var data = JSON.parse($(element).attr('content'));

            $.post(WORKAREA.routes.storefront.recentViewsPath(), data);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.recentViews
         */
        init = function ($scope) {
            $('meta[property="recent-view"]', $scope).each(updateRecentViews);
        };

    return {
        init: init
    };
}()));
