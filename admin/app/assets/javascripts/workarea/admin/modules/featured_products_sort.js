/**
 * @namespace WORKAREA.featuredProductsSort
 */
WORKAREA.registerModule('featuredProductsSort', (function () {
    'use strict';

    var initSorting = function (i, container) {
            $(container).sortable({
                update: function (event, ui) {
                    var $form = $(ui.item).closest('form');
                    $.post($form.attr('action'), $form.serialize());
                }
            });
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.featuredProductsSort
         */
        init = function ($scope) {
            $('[data-featured-products-sort]', $scope).each(initSorting);
        };

    return {
        init: init
    };
}()));
