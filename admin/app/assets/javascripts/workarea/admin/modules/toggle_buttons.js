/**
 * @namespace WORKAREA.toggleButtons
 */
WORKAREA.registerModule('toggleButtons', (function () {
    'use strict';

    var toggleElements = function ($radio, positive) {
            var $container = $radio.closest('[data-toggle-button]'),
                $elements = $('.toggle-button__more', $container),
                reverseSwitch = positive ? 'negative' : 'positive',
                selector = '[data-toggle-button-' + reverseSwitch + '-element]';

            $elements.removeClass('toggle-button__more--active');

            $elements
                .not(selector)
                .addClass('toggle-button__more--active');
        },

        determineState = function ($radio) {
            if ($radio.is('.toggle-button__input--positive')) {
                toggleElements($radio, true);
            } else {
                toggleElements($radio, false);
            }
        },

        getCheckedRadio = function (event) {
            determineState($(event.currentTarget));
        },

        getInitialState = function (index, button) {
            determineState($('.toggle-button__input:checked', button));
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.toggleButtons
         */
        init = function ($scope) {
            $('[data-toggle-button]', $scope)
            .on('change', '.toggle-button__input', getCheckedRadio)
            .each(getInitialState);
        };

    return {
        init: init
    };
}()));
