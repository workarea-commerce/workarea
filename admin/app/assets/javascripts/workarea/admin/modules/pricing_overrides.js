/**
 * Handles the disabling of fields when inputting values for pricing overrides.
 *
 * @namespace WORKAREA.pricingOverrides
 */
WORKAREA.registerModule('pricingOverrides', (function () {
    'use strict';

    var updateForm = function($form, fieldId, response) {
            var $html = $(response),
                $newForm = $html.find('#' + $form.attr('id'));

            $form.replaceWith($newForm);
            WORKAREA.initModules($newForm);
            $('#' + fieldId).trigger('focus');
        },

        postFormData = _.debounce(function (event) {
            var $field = $(event.target),
                $form = $field.closest('form');

            $.post($form.attr('action'), $form.serialize())
            .done(_.partial(updateForm, $form, $field.attr('id')));
        }, WORKAREA.config.formSubmittingControls.inputDelay),

        /**
         * @method
         * @name init
         * @memberof WORKAREA.pricingOverrides
         */
        init = function ($scope) {
            $('[data-pricing-overrides]', $scope).on('change', 'input', postFormData);
        };

    return { init: init };
}()));
