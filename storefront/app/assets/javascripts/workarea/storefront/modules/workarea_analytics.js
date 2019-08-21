/**
 * @method
 * @name registerAdapter
 * @memberof WORKAREA.analytics
 */
WORKAREA.analytics.registerAdapter('workarea', function () {
    'use strict';

    var productsViewed = {},

        saveProductView = function (payload) {
            if (payload.id && !productsViewed[payload.id]) {
                $.ajax({
                    type: 'POST',
                    url: WORKAREA.routes.storefront.analyticsProductViewPath(
                        { product_id: payload.id }
                    ),
                    success: function () {
                        productsViewed[payload.id] = true;
                    }
                });
            }
        };

    return {
        'newSession': function () {
            $.post(WORKAREA.routes.storefront.analyticsNewSessionPath());
        },

        'categoryView': function (payload) {
            if (payload.id && _.isEmpty(payload.filters) && payload.page === 1) {
                $.ajax({
                    type: 'POST',
                    url: WORKAREA.routes.storefront.analyticsCategoryViewPath(
                        { category_id: payload.id }
                    ),
                });
            }
        },

        'productView': saveProductView,
        'productQuickView': saveProductView,

        'searchResultsView': function (payload) {
            if (_.isEmpty(payload.filters) && payload.page === 1) {
                $.ajax({
                    type: 'POST',
                    url: WORKAREA.routes.storefront.analyticsSearchPath(
                        {
                            q: payload.terms,
                            total_results: payload.totalResults
                        }
                    )
                });
            }
        }
    };
});
