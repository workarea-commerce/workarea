/**
 * @namespace WORKAREA.propertyToggles
 */
WORKAREA.registerModule('propertyToggles', (function () {
    'use strict';

    var disableBlankInputs = function (event) {
            $(':input', event.currentTarget).each(function (index, input) {
                if (_.isEmpty($(input).val()) &&
                    _.isUndefined($(input).data('propertyToggleAllowBlank'))) {
                    $(input).prop('disabled', true);
                }
            });
        },

        enableCheckbox = function ($component) {
            $('.property-toggle__checkbox :input', $component)
            .prop('checked', true);
        },

        disableProperty = function ($property) {
            var $input = $(':input', $property);

            $property.removeClass('property-toggle__property--active');

            $input.prop('disabled', true);
        },

        enableProperty = function ($property, focusInput) {
            var $input = $(':input', $property);

            if ($property.hasClass('property-toggle__property--active')) {
                return;
            }

            $property.addClass('property-toggle__property--active');

            $input.prop('disabled', false);

            if (focusInput) {
                $input.eq(0).trigger('focus');
            }
        },

        preserveToggleState = function (index, component) {
            var $checkbox = $('.property-toggle__checkbox :input', component),
                $property = $('.property-toggle__property', component);

            if ($checkbox.prop('checked')) {
                enableProperty($property);
            }
        },

        toggleProperty = function (event) {
            var $component = $(event.delegateTarget),
                $property = $('.property-toggle__property', $component),
                $trigger = $(event.currentTarget);

            if ($trigger.is($property)) {
                enableProperty($property, true);
                enableCheckbox($component);
            } else {
                if ($trigger.prop('checked')) {
                    enableProperty($property, true);
                } else {
                    disableProperty($property);
                }
            }
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.propertyToggles
         */
        init = function ($scope) {
            $('.property-toggle', $scope)
            .on('change', '.property-toggle__checkbox :input', toggleProperty)
            .on('click', '.property-toggle__property', toggleProperty)
            .each(preserveToggleState)
                .closest('form')
                .on('submit', disableBlankInputs);
        };

    return {
        init: init
    };
}()));
