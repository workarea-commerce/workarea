/**
 * @namespace WORKAREA.datetimepickerFields
 */
WORKAREA.registerModule('datetimepickerFields', (function () {
    'use strict';

    var altFieldId = function (input, options) {
            if(options.inline) {
                return '#' + $(input).attr('id') + WORKAREA.config.datetimepickerFields.fieldSuffixes.date;
            } else {
                return '';
            }
        },

        getConfig = function (input, options) {
            return _.merge(
                {},
                WORKAREA.config.datepickerFields.uiOptions,
                options.uiOptions || {},
                {
                    altField: altFieldId(input, options)
                }
            );
        },

        twentyFourHourHours = function(hours, ampm) {
            if (hours !== 12) {
                return ampm === 'pm' ? hours + 12 : hours;
            } else if(ampm === 'am') {
                return 0;
            } else {
                return 12;
            }
        },

        composeDate = function($dateTimePicker, inputId) {
            var fieldSuffixes = WORKAREA.config.datetimepickerFields.fieldSuffixes,
                date = $dateTimePicker.find('#' + inputId + fieldSuffixes.date).val(),
                hours = parseInt($dateTimePicker.find('#' + inputId + fieldSuffixes.hours).val()),
                minutes = $dateTimePicker.find('#' + inputId + fieldSuffixes.minutes).val(),
                ampm = $dateTimePicker.find('#' + inputId + fieldSuffixes.ampm).val(),
                dateParts = date.toString().split('-');

            if (_.isEmpty(date)) {
                return '';
            } else {
                return new Date(
                    dateParts[0],
                    dateParts[1] -1, //Date counts months from 0
                    dateParts[2],
                    twentyFourHourHours(hours, ampm),
                    minutes
                );
            }
        },

        updateDateTimeField = function($input, $dateTimePicker) {
            var dateTime = composeDate($dateTimePicker, $input.attr('id'));

            $input.val(WORKAREA.date.formatDateTime(dateTime));
        },

        serializeOnSubmit = function($dateTimePicker, $input) {
            var $form = $input.closest('form');

            $form.on('submit', function () {
                updateDateTimeField($input, $dateTimePicker);
            });
        },

        parseDate = function($dateField) {
            return {
                hours: WORKAREA.date.parseHoursFromDate($dateField.val()),
                minutes: WORKAREA.date.parseMinutesFromDate($dateField.val()),
                ampm: WORKAREA.date.parseAmPmFromDate($dateField.val())
            };
        },

        getCalendar = function($dateTimePicker, $input) {
            return $dateTimePicker.find('#' + $input.attr('id') + WORKAREA.config.datetimepickerFields.fieldSuffixes.picker);
        },

        clearDatepickerActiveState = function($inlineCalendar) {
            $('.ui-state-highlight.ui-state-active', $inlineCalendar)
            .removeClass('ui-state-highlight ui-state-active');
        },

        handleDateFieldChange = function($inlineCalendar, event) {
            var $dateField = $(event.currentTarget),
                dateValue = $dateField.val();

            if (WORKAREA.date.testDateFormat(dateValue)) {
                $inlineCalendar.datepicker('setDate', dateValue);
            } else {
                clearDatepickerActiveState($inlineCalendar);
            }
        },

        datepickerAlreadyInjected = function($input) {
            return !_.isEmpty($input.siblings('.datetimepicker'));
        },

        injectUI = function($input) {
            var required = !_.isEmpty($input.attr('required')) ? 'required' : '',
                placeholder = JST['workarea/admin/templates/datetime_picker']({
                id: $input.attr('id'),
                initialDateTime: parseDate($input),
                fieldSuffixes: WORKAREA.config.datetimepickerFields.fieldSuffixes,
                name: $input.attr('id'),
                required: required
            });

            // Prevents UI being injected twice on browser back
            // this condition is only needed because of turbolinks
            if (datepickerAlreadyInjected($input)) {
                $input.siblings('.datetimepicker').remove();
            }

            $input.before(placeholder);

            return $input.siblings('.datetimepicker');
        },

        initInlineDatetimePicker = function (index, input) {
            var $input = $(input),
                options = $input.data('datetimepickerField'),
                $dateTimePicker = injectUI($input),
                $inlineCalendar = getCalendar($dateTimePicker, $input),
                $dateField = $('[data-datetimepicker-field-date-input]', $dateTimePicker);

            $inlineCalendar.datepicker(getConfig(input, options));

            // Set the initial state of the datepicker inputs
            if (_.isEmpty($input.val())) {
                $inlineCalendar.datepicker('setDate', null);
                //Active state isn't cleared by datepicker setDate: null
                clearDatepickerActiveState($inlineCalendar);
            } else {
                $inlineCalendar.datepicker('setDate', WORKAREA.date.formatDateTime($input.val()));
            }

            // On form submit serialize the injected date/time inputs back into the hidden field
            serializeOnSubmit($dateTimePicker, $input);

            // Update the calendar UI when the date input changes
            $dateField.on('keyup input', _.partial(handleDateFieldChange, $inlineCalendar));
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.datetimepickerFields
         */
        init = function ($scope) {
            $('[data-datetimepicker-field]', $scope).each(initInlineDatetimePicker);
        };

    return {
        init: init,
        updateDateTimeField: updateDateTimeField
    };
}()));
