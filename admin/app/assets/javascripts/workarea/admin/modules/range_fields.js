/**
 * @namespace WORKAREA.rangeFields
 */
WORKAREA.registerModule('rangeFields', (function () {
    'use strict';

    var inputHandler = function (field, type, event) {
            var property = $(field).closest('.property');

            event.preventDefault();

            $('input[type=' +type+']', property).val($(event.currentTarget).val());
        },

        setupField = function (index, field) {
            $('input[type="range"]', field)
            .on('input change', _.partial(inputHandler, field, 'number'));

            $('input[type="number"]', field)
            .on('input change', _.partial(inputHandler, field, 'range'));
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.rangeFields
         */
        init = function ($scope) {
            $('[data-range-field]', $scope).each(setupField);
        };

    return {
        init: init
    };
}()));
