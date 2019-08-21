/**
 * @namespace WORKAREA.formSubmittingControls
 */
WORKAREA.registerModule('formSubmittingControls', (function () {
    'use strict';

    var changingNumberInput = function (event) {
            return event.target.type === 'number' && event.type === 'change';
        },

        submitClosestForm = function (event) {
            var $form = $(event.delegateTarget);

            if (changingNumberInput(event)) { return; }

            if (!$form.data('wasSubmitted')) {
                $form.trigger('submit');
                $form.data('wasSubmitted', typeof $form.valid !== 'function' || $form.valid());
            }
        },

        handleFieldChange = _.debounce(submitClosestForm, function () {
            if (WORKAREA.environment.isTest) {
                return 0;
            } else {
                return WORKAREA.config.formSubmittingControls.changeDelay;
            }
        }()),

        handleFieldInput = _.debounce(submitClosestForm, function () {
            if (WORKAREA.environment.isTest) {
                return 0;
            } else {
                return WORKAREA.config.formSubmittingControls.inputDelay;
            }
        }()),

        /**
         * @method
         * @name init
         * @memberof WORKAREA.formSubmittingControls
         */
        init = function ($scope) {
            $('form', $scope).has('[data-form-submitting-control]')
            .on('change', '[data-form-submitting-control]', handleFieldChange)
            .on('input', '[data-form-submitting-control]', handleFieldInput);
        };

    return {
        init: init
    };
}()));
