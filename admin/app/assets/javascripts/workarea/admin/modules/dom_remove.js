/**
 * @namespace WORKAREA.domRemove
 */
WORKAREA.registerModule('domRemove', (function () {
    'use strict';

    var removeSummary = function (event, confirmed) {
            var $target = $(event.delegateTarget),
                selector = $target.data('domRemove');

            if (_.isEmpty($target.filter('[data-confirm]')) || confirmed) {
                $target.closest(selector).fadeOut(function() { $(this).remove(); });
            } else {
                $target.one('confirm:complete', removeSummary);
            }
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.domRemove
         */
        init = function ($scope) {
            $('[data-dom-remove]', $scope).on('click', removeSummary);
        };

    return {
        init: init
    };
}()));
