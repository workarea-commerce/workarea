/**
 * @namespace WORKAREA.productImagesSortables
 */
WORKAREA.registerModule('productImagesSortables', (function () {
    'use strict';

    var onUpdate = function () {
            var $group = $(this).closest(
                    '[data-product-images-sortable-group]'
                ),

                positions = $('[name$="position]"]', $group).map(function () {
                    return $(this).closest('[data-image-id]').data('imageId');
                }),

                data = _.map(positions, function (position) {
                    return 'order[]=' + position;
                }),

                url = $group.data('productImagesSortableGroup').url;

            $.ajax({
                url: url,
                method: 'POST',
                data: data.join('&'),
                success: function () {
                    WORKAREA.messages.insertMessage(
                        I18n.t('workarea.admin.js.product_images_sortables.success_message'),
                        'success'
                    );
                },
                error: function () {
                    WORKAREA.messages.insertMessage(
                        I18n.t('workarea.admin.js.product_images_sortables.error_message'),
                        'error'
                    );
                }
            });
        },

        getConfig = function () {
            return _.assign({}, WORKAREA.config.productImagesSortable, {
                update: onUpdate
            });
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.productImagesSortables
         */
        init = function ($scope) {
            $('[data-product-images-sortable]', $scope).sortable(getConfig());
        };

    return {
        init: init
    };
}()));
