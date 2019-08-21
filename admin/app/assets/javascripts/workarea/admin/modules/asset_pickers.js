/**
 * @namespace WORKAREA.assetPickers
 */
WORKAREA.registerModule('assetPickers', (function () {
    'use strict';

    var announceEvent = function (summary) {
            var data = $(summary).data('asset');

            $(window).trigger('assetPickers:insert', data);

            WORKAREA.takeover.close();
        },

        requestPage = function (requestData) {
            $.get(requestData.endpoint, requestData.data || {})
            .done(WORKAREA.takeover.update);
        },

        getRequestData = function (element) {
            var requestData = {};

            if (_.isUndefined(element.action)) {
                requestData.endpoint = element.href;
            } else {
                requestData.endpoint = element.action;
                requestData.data = $(element).serialize();
            }

            return requestData;
        },

        stopEvent = function (event) {
            event.preventDefault();
            return event.currentTarget;
        },

        handleSummaryClick = _.flow(stopEvent, announceEvent),

        /**
         * Handles a click or submit event asyncronously, replacing the current
         * Takeover with the content from the async call.
         * @type {function}
         * @param {event} event the click or submit event
         */
        handleInteraction = _.flow(stopEvent, getRequestData, requestPage),

        /**
         * @method
         * @name init
         * @memberof WORKAREA.assetPickers
         */
        init = function ($scope) {
            $('[data-asset-picker]', $scope)
                .addBack('[data-asset-picker]')
                .on('submit', 'form', handleInteraction)
                .on('click', 'a:not([data-asset])', handleInteraction)
                .on('click', '[data-asset]', handleSummaryClick);
        };

    return {
        init: init,
        handleInteraction: handleInteraction
    };
}()));
