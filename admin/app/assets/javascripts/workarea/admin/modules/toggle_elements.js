/**
 * @namespace WORKAREA.toggleElement
 */
WORKAREA.registerModule('toggleElement', (function () {
    'use strict';

    /**
     * @method
     * @name init
     * @memberof WORKAREA.toggleElement
     */
    var toggle = function (event) {
            var $target = $(event.target).data('toggle');

            event.preventDefault();

            $target.toggleClass('hidden');
        },

        init = function ($scope) {
            $('[data-toggle-element]', $scope).on('click', toggle);
        };

    return {
        init: init
    };
}()));
