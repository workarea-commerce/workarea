/**
 * @namespace WORKAREA.searchFields
 */
WORKAREA.registerModule('searchFields', (function () {
    'use strict';

    var getSource = function (request, response) {
            var endpoint = WORKAREA.routes.storefront.searchesPath();

            $.getJSON(endpoint, { q: request.term }, function (data) {
                response(data.results);
            });
        },

        openSelected = function (event, ui) {
            if (ui.item.type === "Products") {
                WORKAREA.analytics.fireCallback(
                    'productClick',
                    ui.item.analytics
                );
            }

            if (WORKAREA.analytics.domEventsDisabled()) { return; }
            window.location = ui.item.url;
        },

        /**
         * iOS touch devices treat touch events as mouseenter unless there is no
         * change in the UI, like a menu-selected state. By unbinding the
         * mouseenter event we force those devices to treat the touch event as a
         * click. This prevents the user having to tap twice to open a search
         * autocomplete result.
         */
        openOnTouchDevices = function () {
            $('.ui-autocomplete').off('mouseenter');
        },

        getConfig = function () {
            return _.assign({}, WORKAREA.config.searchFieldsAutocomplete, {
                source: getSource,
                select: openSelected,
                open: openOnTouchDevices
            });
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.searchFields
         */
        init = function ($scope) {
            $('[data-search-field]', $scope)
            .categorizedAutocomplete(getConfig());
        };

    return {
        init: init
    };
}()));
