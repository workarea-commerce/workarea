/**
 * @namespace WORKAREA.checkoutShippingServices
 */
WORKAREA.registerModule('checkoutShippingServices', (function () {
    'use strict';

    var updateCheckoutStepSummary = function (response, $container) {
            var $response = $(response);
            $('.checkout-step-summary', $container).replaceWith($response);
            WORKAREA.initModules($response);
        },

        enableSubmit = function ($form) {
            $('button[type=submit]', $form).prop('disabled', false);
            $('input[type=radio]', $form).prop('disabled', false);
        },

        disableSubmit = function ($form) {
            $('button[type=submit]', $form).prop('disabled', 'disabled');
            $('input[type=radio]', $form).prop('disabled', 'disabled');
        },

        handleShippingChange = _.debounce(function (event) {
            var $shippingForm = $(event.currentTarget).closest('form'),
                $container = $shippingForm.closest('.page-content'),
                url = $shippingForm.attr('action'),
                data = $shippingForm.serialize(),
                updatingShipping = $.post(url, data);

            disableSubmit($shippingForm);

            updatingShipping.done(function (response) {
                updateCheckoutStepSummary(response, $container);
                enableSubmit($shippingForm);
            });
        }, WORKAREA.config.checkoutShippingServices.requestTimeout),

        /**
         * @method
         * @name init
         * @memberof WORKAREA.checkoutShippingServices
         */
        init = function ($scope) {
            $('[data-checkout-shipping-service]', $scope).on('change', [
                '[name=shipping_service]', // TODO: v4 use only data attr
                '[data-checkout-shipping-service-option]'
            ].join(','), handleShippingChange);
        };

    return {
        init: init
    };
}()));
