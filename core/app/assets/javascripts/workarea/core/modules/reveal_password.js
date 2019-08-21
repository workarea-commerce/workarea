/**
 * @namespace WORKAREA.revealPassword
 */
WORKAREA.registerModule('revealPassword', (function () {
    'use strict';

    var buttonTemplate = JST['workarea/core/templates/reveal_password_button'],

        toggleButton = function ($field, event) {
            var $button = $(event.currentTarget);

            $button.addClass('hidden');
            $button.siblings('[data-reveal-password]').removeClass('hidden');

            if ($button.data('revealPassword') === 'show') {
                $field.attr('type', 'text');
            } else {
                $field.attr('type', 'password');
            }
        },

        bindButtonEvents = function ($field) {
            var $container = $field.closest('.property');

            $('[data-reveal-password]', $container)
            .on('click', _.partial(toggleButton, $field));
        },

        injectButtons = function (index, field) {
            return $(field).after(buttonTemplate());
        },

        initRevealPassword = _.flow(injectButtons, bindButtonEvents),

        /**
         * @method
         * @name init
         * @memberof WORKAREA.revealPassword
         */
        init = function ($scope) {
            $('input[type=password]', $scope).each(initRevealPassword);
        };

    return {
        init: init
    };
}()));
