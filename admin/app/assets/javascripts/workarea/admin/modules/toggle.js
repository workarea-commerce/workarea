/**
 * @namespace WORKAREA.toggle
 */
WORKAREA.registerModule('toggle', (function () {
    'use strict';

    /**
     * @method
     * @name init
     * @memberof WORKAREA.toggle
     */
    var init = function ($scope) {
        $('[data-toggle]', $scope).on('click', function(event) {
            $($(event.target).data('toggle')).toggleClass('hidden');
        });
    };

    return {
        init: init
    };
}()));
