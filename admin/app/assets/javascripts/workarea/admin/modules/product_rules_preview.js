/**
 * @namespace WORKAREA.productRulesPreview
 */
WORKAREA.registerModule('productRulesPreview', (function () {
    'use strict';

    var $previewDisplay = null,

        replaceResults = function (input) {
            var $form = $(input).closest('form'),
                url = WORKAREA.routes.admin.previewProductListProductRulePath({
                    product_list_id: $form.data('productListId'),
                    id: $form.data('ruleId'),
                    _options: true
                });

            $.ajax({
                url: url,
                data: $form.serialize(),
                method: 'GET',
                success: function (result) {
                    $previewDisplay.parent().addClass('product-rules-preview--flash');
                    $previewDisplay.html(result);

                    _.delay(function () {
                        $previewDisplay.parent().removeClass('product-rules-preview--flash');
                    }, 50);
                }
            });
        },

        updatePreview = _.debounce(function (event) {
            replaceResults(event.target);
        }, 300),

        /**
         * @method
         * @name init
         * @memberof WORKAREA.productRulesPreview
         */
        init = function ($scope) {
            $previewDisplay = $('#product-rules-preview');

            $('[data-product-rules-preview]', $scope)
            .on('keyup blur change select2:select select2:unselect', updatePreview);
        };

    return {
        init: init
    };
}()));
