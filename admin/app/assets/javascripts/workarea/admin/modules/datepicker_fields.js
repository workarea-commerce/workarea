/**
 * @namespace WORKAREA.datepickerFields
 */
WORKAREA.registerModule('datepickerFields', (function () {
    'use strict';

    var setDates = function (event) {
            var dates = event.target.value.split('|'),
                range = { starts_at: dates[0], ends_at: dates[1] || dates[0] },
                $ui = $(event.delegateTarget),
                $startsAt = $ui.find('[data-datepicker-field-starts-at]'),
                $endsAt = $ui.find('[data-datepicker-field-ends-at]');

            $startsAt.data('datepicker').datepicker('setDate', range.starts_at);
            $endsAt.data('datepicker').datepicker('setDate', range.ends_at);
        },

        getConfig = function (input, options) {
            return _.merge(
                {},
                WORKAREA.config.datepickerFields.uiOptions,
                options.uiOptions || {}
            );
        },

        clearDatepickerActiveState = function($inlineCalendar) {
            $('.ui-state-highlight.ui-state-active', $inlineCalendar)
            .removeClass('ui-state-highlight ui-state-active');
        },

        datepickerAlreadyInjected = function($input) {
            return !_.isEmpty($input.siblings('.datepicker--inline'));
        },

        injectInlinePlaceholder = function($input, inputId) {
            var placeholder = JST['workarea/admin/templates/inline_datepicker']({
                id: inputId
            });

            // Remove the UI if it was already injected
            // this condition is only needed because of turbolinks
            if (datepickerAlreadyInjected($input)) {
                $input.siblings('.datepicker--inline').remove();
            }

            $input.before(placeholder);

            return $input.siblings('.datepicker--inline');
        },

        initInlineDatePicker = function (input, options) {
            var $input = $(input),
                initialValue = $(input).val(),
                inputId = $input.attr('id'),
                $inlineCalendar = injectInlinePlaceholder($input, inputId);

            if (_.isUndefined(options.uiOptions)) {
                options.uiOptions = {};
            }

            options.uiOptions.altField = '#' + inputId;

            $inlineCalendar.datepicker(getConfig(input, options));
            $input.data('datepicker', $inlineCalendar);

            if (_.isEmpty(initialValue)) {
                $inlineCalendar.datepicker('setDate', null);
                //Active state isn't cleared by datepicker setDate: null
                clearDatepickerActiveState($inlineCalendar);
            } else {
                $inlineCalendar.datepicker('setDate', WORKAREA.date.formatDate(initialValue));
            }
        },

        initDatepicker = function (input, options) {
            var $input = $(input),
                initialValue = $input.val();

            $input.datepicker(getConfig(input, options));

            if (_.isEmpty(initialValue)) {
                $input.datepicker('setDate', null);
            } else {
                $input.datepicker('setDate', WORKAREA.date.formatDate(initialValue));
            }
        },

        initByType = function (index, input) {
            var options = $(input).data('datepickerField');

            if (options.inline) {
                initInlineDatePicker(input, options);
            } else {
                initDatepicker(input, options);
            }
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.datepickerFields
         */
        init = function ($scope) {
            $('[data-datepicker-field]', $scope)
            .each(initByType)
                .closest('.browsing-controls__filter-dropdown')
                .on('change', '[name=quick_range]', setDates);
        };

    return {
        init: init
    };
}()));
