/**
 * @namespace WORKAREA.expandables
 */
WORKAREA.registerModule('expandables', (function () {
    'use strict';

    var getThreshold = function ($element) {
            return _.min([
                WORKAREA.config.expandable.threshold,
                $element.data('expandable') || undefined
            ]);
        },

        expand = function (event) {
            var $ui = $(event.target).closest('.expandable');

            $ui.addClass('expandable--expanded');

            $ui.find('.expandable__element').css({
                maxHeight: 'none'
            });
        },

        addButton = function ($ui) {
            var button = JST['workarea/admin/templates/expandable_button']();

            $(button)
            .on('click', expand)
            .appendTo($ui);
        },

        setHeight = function ($element) {
            $element.css({
                maxHeight: getThreshold($element)
            });
        },

        addUI = function ($element) {
            $element.addClass('expandable__element');
            return $element.wrap('<div class="expandable" />').parent();
        },

        setup = function ($element) {
            var $ui = addUI($element);
            setHeight($element);
            addButton($ui);
        },

        testHeight = function (index, element) {
            var $element = $(element),
                threshold = getThreshold($element);

            if ($element.height() < threshold) { return; }

            setup($element);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.expandables
         */
        init = function ($scope) {
            $('[data-expandable]', $scope).each(testHeight);
        };

    return {
        init: init
    };
}()));
