/**
 * Appends a `.back-to-top-button` component to the document's body.
 *
 * @namespace WORKAREA.backToTopButton
 */
WORKAREA.registerModule('backToTopButton', (function () {
    'use strict';

    var backToTopButton = JST['workarea/storefront/templates/back_to_top_button'],

        toggleBackToTop = function (direction) {
            $('#back-to-top-button')
            .toggleClass('back-to-top-button--visible', direction === 'down');
        },

        initWaypoint = function (element) {
            $(element).data('backToTopWaypoint', new Waypoint({
                element: element,
                handler: toggleBackToTop,
                offset: WORKAREA.config.backToTopButton.waypointOffset
            }));
        },

        injectButton = function (index, element) {
            $('#main_content').append(backToTopButton());
            return element;
        },

        setup = _.flow(injectButton, initWaypoint),

        /**
         * Add a `data-back-to-top-button` attribute to any element that should
         * be used as a Waypoint trigger that conditionally displays a global
         * "Back To Top" button UI.
         *
         * @method
         * @name init
         * @memberof WORKAREA.backToTopButton
         */
        init = function ($scope) {
            $('[data-back-to-top-button]', $scope).each(setup);
        };

    return {
        init: init
    };
}()));
