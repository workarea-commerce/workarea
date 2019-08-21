/**
 * @namespace WORKAREA.optionalFields
 */
WORKAREA.registerModule('optionalFields', (function () {
    'use strict';

    var prompt = JST['workarea/storefront/templates/optional_field_prompt'],

        reveal = function ($container, $prompt, event) {
            event.preventDefault();
            event.stopPropagation();
            $prompt.remove();
            $container.removeClass('hidden-if-js-enabled');
            $container.find(':focusable').first().trigger('focus');
        },

        inject = function ($prompt, $container) {
            $container.before($prompt);
        },

        build = function ($container) {
            var $prompt = $(prompt({
                text: $container.data('optionalField')
            }));

            $prompt.on('click', _.partial(reveal, $container, $prompt));
            $container.on('change', _.partial(reveal, $container, $prompt));

            return $prompt;
        },

        setup = function (index, container) {
            var $container = $(container);
            inject(build($container), $container);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.optionalFields
         */
        init = function ($scope) {
            $('[data-optional-field]', $scope).each(setup);
        };

    return {
        init: init
    };
}()));
