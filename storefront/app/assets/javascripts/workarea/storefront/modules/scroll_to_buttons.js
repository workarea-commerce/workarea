/**
 * @namespace WORKAREA.scrollToButtons
 */
WORKAREA.registerModule('scrollToButtons', (function () {
    'use strict';

    var scrollToElement = function ($element) {
            $('html, body').animate({
                scrollTop: $element.offset().top - WORKAREA.config.scrollToButtons.topOffset
            }, WORKAREA.config.scrollToButtons.animationSpeed);
        },

        testElement = function (event) {
            var $view = $(event.currentTarget).closest('.view'),
                $targetElement = $view.find(event.currentTarget.hash);

            if (_.isEmpty($targetElement)) { return; }

            event.preventDefault();

            WORKAREA.scrollToButtons.scrollToElement($targetElement);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.scrollToButtons
         */
        init = function ($scope) {
            $('[data-scroll-to-button]', $scope).on('click', testElement);
        };

    return {
        init: init,
        scrollToElement: scrollToElement
    };
}()));
