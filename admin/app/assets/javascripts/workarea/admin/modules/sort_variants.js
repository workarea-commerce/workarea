/**
 * @namespace WORKAREA.sortVariants
 */
WORKAREA.registerModule('sortVariants', (function () {
    'use strict';

    var findVariantPositions = function (event) {
            var result = {},
                $variants = $('[data-sort-variant-id]', event.target);

            $variants.each(function (index, menu) {
                var id = $(menu).data('sortVariantId');

                if (id) {
                    result['positions[' + id + ']'] = index;
                }
            });

            return result;
        },

        saveSort = function (event) {
            var productId = $(event.target)
                                .closest('[data-sort-variant]')
                                .data('productId'),

                url = WORKAREA.routes.admin.moveCatalogProductVariantsPath(
                    { catalog_product_id: productId }
                );

            $.post(url, findVariantPositions(event));
        },

        setCellWidth = function (event, ui) {
            $('td', ui.item).each(function (index, cell) {
                $(cell).width($(cell).width());
            });

            return ui;
        },

        resetCellWidth = function (event, ui) {
            $('td', ui.item).each(function (index, cell) {
                $(cell).width('auto');
            });

            return ui;
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.sortVariants
         */
        init = function ($scope) {
            $('[data-sort-variant]', $scope).sortable({
                axis: 'y',
                update: saveSort,
                helper: setCellWidth,
                stop: resetCellWidth
            });
        };

    return {
        init: init
    };
}()));
