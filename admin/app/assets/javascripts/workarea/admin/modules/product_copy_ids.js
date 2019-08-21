/**
 * @namespace WORKAREA.productCopyIds
 */
WORKAREA.registerModule('productCopyIds', (function () {
    'use strict';

    var randomizeID = function (event) {
            var form = event.delegateTarget,
                $target = $('[name="product[id]"]', form),
                hash = Math.random().toString(32).slice(2).toUpperCase();

            $target.val(hash);
        },

        copyOriginalID = function (event) {
            var form = event.delegateTarget,
                id = $('[name=source_product_id]', form).val(),
                $target = $('[name="product[id]"]', form);

            $target.val(id + '-copy');
        },

        setProductId = function(event) {
            var form = event.delegateTarget,
                $target = $('[name=original_id]', form),
                $containers = $('.property.hidden', form);

            $target.val(event.target.value);
            $containers.removeClass('hidden');
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.productCopyIds
         */
        init = function ($scope) {
            $('[data-product-copy-ids]', $scope)
            .on('change', 'select[name=source_product_id]', setProductId)
            .on('click', 'button[value=copy_original]', copyOriginalID)
            .on('click', 'button[value=randomize]', randomizeID);
        };

    return {
        init: init
    };
}()));
