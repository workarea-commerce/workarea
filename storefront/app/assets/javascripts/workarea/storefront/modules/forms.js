/**
 * @namespace WORKAREA.forms
 */
WORKAREA.registerModule('forms', (function () {
    'use strict';

    var invalidateProperty = function (index, error) {
            $(error).closest('.property').addClass('property--invalid');
        },

        displayError = function ($error, $element) {
            $error.addClass(WORKAREA.config.forms.errorLabelClasses);
            $element.closest('.value').append($error);
        },

        validateTextBox = function (element) {
            var $textBox = $(element);

            $textBox.removeClass('text-box--valid text-box--invalid');

            if ($textBox.valid()) {
                if ($textBox.val()) {
                    $textBox.addClass('text-box--valid');
                }
            } else {
                $textBox.addClass('text-box--invalid');
            }
        },

        validateElement = function (element) {
            var $input = $(element),
                $property = $input.closest('.property');

            if ($input.valid()) {
                $property.removeClass('property--invalid');
                $property.find('.value__error').remove();
            } else {
                $property.addClass('property--invalid');
            }

            if ($(element).is('.text-box')) {
                validateTextBox(element);
            }
        },

        checkAllControls = function (event) {
            var $form = $(event.delegateTarget);

            if ($form.valid()) { return; }

            $(':input', $form).each(_.rearg(validateElement, [1, 0]));
        },

        /**
         * This is being debounced because jQuery validation fires twice when the
         * form is submitted.
         */
        fireAnalytics = _.debounce(
            function () {
                WORKAREA.analytics.fireCallback('validationError', {});
            },
            WORKAREA.config.validationErrorAnalyticsThrottle || 1000
        ),

        validateForm = function (index, form) {
            $(form).validate({
                onfocusout: validateElement,
                errorPlacement: displayError,
                invalidHandler: function () {
                    if (WORKAREA.analytics) {
                        fireAnalytics();
                    }
                }
            });

            $(form).on('submit', checkAllControls);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.forms
         */
        init = function ($scope) {
            $('form', $scope)
            .each(validateForm)
                .find('.value__error')
                .each(invalidateProperty);
        };

    return {
        init: init
    };
}()));
