/**
 * @namespace WORKAREA.checkoutPrimaryPayments
 */
WORKAREA.registerModule('checkoutPrimaryPayments', (function () {
    'use strict';

    var fieldExists = function ($field) {
            return !_.isEmpty($field);
        },

        fieldNeedsRule = function ($field) {
            return !$field.rules().creditcard;
        },

        addCreditCardValidation = function ($form) {
            var $field = $('[name="credit_card[number]"]', $form);

            if (fieldExists($field) && fieldNeedsRule($field)) {
                $form
                    .find('input[name="credit_card[number]"]')
                    .rules('add', { extendedCreditCard: true });
            }
        },

        handlePaymentMethodClick = function (event) {
            $(event.currentTarget)
                .find('input[name="payment"]')
                .prop('checked', true)
                .trigger('change');
        },

        activatePaymentMethod = function (event) {
            var $selection = $(event.currentTarget),
                $form = $selection.closest('form'),
                $all = $form.find('.checkout-payment__primary-method'),
                $current = $selection.closest('.checkout-payment__primary-method');

            $all.removeClass('checkout-payment__primary-method--selected');
            $current.addClass('checkout-payment__primary-method--selected');
        },

        setupForm = function (index, section) {
            var $form = $('form', section);

            addCreditCardValidation($form);

            $('input[name="payment"]', $form)
            .on('change', activatePaymentMethod);

            $('.checkout-payment__primary-method', $form)
            .on('click', handlePaymentMethodClick);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.checkoutPrimaryPayments
         */
        init = function ($scope) {
            $('[data-checkout-primary-payment]', $scope).each(setupForm);
        };

    return {
        init: init
    };
}()));
