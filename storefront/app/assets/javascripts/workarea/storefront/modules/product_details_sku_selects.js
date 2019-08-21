/**
 * @namespace WORKAREA.productDetailsSkuSelects
 */
WORKAREA.registerModule('productDetailsSkuSelects', (function () {
    'use strict';

    var getNewURL = function (optionParams) {
            var urlParams = WORKAREA.url.parse(window.location.href).queryKey,
                params = _.omitBy(urlParams, function (value, key) { return key === 'sku'; }),
                queryString;

            optionParams = WORKAREA.url.parse('/?' + optionParams).queryKey;

            params = _.omitBy(
                _.merge(params, optionParams),
                function (value) { return _.isEmpty(value); }
            );

            // decode params so they do not get double-encoded
            _.forEach(params, function(value, key) {
                params[key] = decodeURIComponent(value);
            });

            queryString = _.isEmpty(params) ? '' : '?' + $.param(params);
            return window.location.pathname + queryString;
        },

        replaceProductDetails = function ($container, optionParams, newDetails) {
            var $newDetails = $(newDetails)
                                  .find('.product-details')
                                      .addBack('.product-details'),
                $allDetails = $('.product-details'),
                $parentDialog = WORKAREA.dialog.closest($container);

            $container.replaceWith($newDetails);

            if ($allDetails.length <= 1 && _.isEmpty($parentDialog)) {
                window.history.replaceState(null, null, getNewURL(optionParams));
            }

            WORKAREA.initModules($newDetails);
        },

        disableAddToCart = function ($form) {
            $form.find(':input').attr('disabled', 'disabled');
        },

        enableAddToCart = function ($form) {
            $form.find(':input').removeAttr('disabled');
        },

        getDetailParams = function($form) {
            return $form.find(':input').not(':hidden').add('input[name=via]', $form).serialize();
        },

        handleSkuSelection = function (event) {
            var $select = $(event.currentTarget),
                $productDetailContainer = $select.closest('.product-details'),
                $form = $select.closest('form'),
                slug = $select.data('productDetailsSkuSelect'),
                endpoint = WORKAREA.routes.storefront.detailsProductPath(slug),
                detailParams = getDetailParams($form),
                promise;

            event.preventDefault();
            disableAddToCart($form);

            promise = $.get(endpoint, detailParams).done(function (html) {
                replaceProductDetails(
                    $productDetailContainer,
                    detailParams,
                    html
                );

                enableAddToCart($form);
            });

            WORKAREA.loading.createLoadingDialog(promise);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.productDetailsSkuSelects
         */
        init = function ($scope) {
            $('[data-product-details-sku-select]', $scope)
            .on('change', handleSkuSelection);
        };

    return {
        init: init
    };
}()));
