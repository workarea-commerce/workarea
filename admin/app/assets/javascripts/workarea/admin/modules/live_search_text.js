/**
 * Handles the faux-typing effect featured within `live-search` components.
 *
 * TODO remove in v4, not used >= 3.4
 *
 * @namespace WORKAREA.liveSearchText
 */
WORKAREA.registerModule('liveSearchText', (function () {
    'use strict';

    var typeString = function (container) {
            var index = $(container).data('liveSearchStringIndex'),
                strings = $(container).data('liveSearchText'),
                string = strings[index];

            $(container).text(string);

            $(container).liveType({
                typeSpeed: 75
            });

            if (_.isUndefined(strings[index + 1])) {
                $(container).data('liveSearchStringIndex', 0);
            } else {
                $(container).data('liveSearchStringIndex', index + 1);
            }
        },

        gatherStrings = function (index, container) {
            $(container).data('liveSearchStringIndex', 0);

            typeString(container);

            window.setInterval(_.partial(typeString, container), 5000);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.liveSearchText
         */
        init = function ($scope) {
            $('[data-live-search-text]', $scope).each(gatherStrings);
        };

    return {
        init: init
    };
}()));
