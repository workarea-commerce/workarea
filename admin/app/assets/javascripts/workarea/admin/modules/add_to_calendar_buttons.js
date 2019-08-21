/**
 * @namespace WORKAREA.addToCalendarButtons
 */
WORKAREA.registerModule('addToCalendarButtons', (function () {
    'use strict';

    var toggleContent = function ($button, $moreInfo, event) {
            event.preventDefault();
            $button.tooltipster('content', $moreInfo);
        },

        initTooltip = function (button, $content) {
            var config = _.merge({}, WORKAREA.config.tooltipster, {
                    content: $content,
                    interactive: true
                });

            return $(button).tooltipster(config);
        },

        setup = function (index, button) {
            var data = $(button).data('addToCalendarButton'),
                $initial = $(data.initial),
                $moreInfo = $(data.moreInfo),
                $button = initTooltip(button, $initial),
                toggle = _.partial(toggleContent, $button, $moreInfo);

            $initial
                .find('[data-add-to-calendar-button-toggle]')
                .on('click', toggle);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.addToCalendarButtons
         */
        init = function ($scope) {
            $('[data-add-to-calendar-button]', $scope).each(setup);
        };

    return {
        init: init
    };
}()));
