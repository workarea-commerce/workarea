/**
 * @namespace WORKAREA.date
 */
WORKAREA.registerModule('date', (function () {
    'use strict';

    var // Due to the way this module is supplied dates from Rails, we are
        // unable to parse the proper DateTime string for all browsers with
        // 100% accuracy. The solution here attempts to get as close as possible
        // to the supplied date as a shoddy workaround.
        // More info: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date#Timestamp_string
        constructDate = function (value) {
            var date = new Date(value),
                dateParts;

            if ( ! isNaN(date)) { return date; }

            dateParts = value.split(' ')[0].split('-');

            return new Date(
                parseInt(dateParts[0]),
                parseInt(dateParts[1]) - 1,
                parseInt(dateParts[2])
            );
        },

        testDateFormat = function(date) {
            return (/^\d{4}-\d{2}-\d{2}$/).test(date.toString());
        },

        tryReformatDateStringWithTimezone = function (value) {
            var result = null,
                needsReformatted = /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} (-|\+)?\d{4}$/,
                pieces = null,
                timezonePrefix = null,
                timezoneMinutes = null;

            if (typeof value !== 'string' || !needsReformatted.test(value)) {
                result = value;
            } else {
                pieces = value.split(' ');
                timezonePrefix = pieces[2].substr(0, pieces[2].length - 2);
                timezoneMinutes = pieces[2].slice(-2);
                result = pieces[0] + 'T' + pieces[1] + timezonePrefix + ':' + timezoneMinutes;
            }

            return result;
        },

        formatDate = function (value) {
            var date;

            if (testDateFormat(value)) {
                var dateParts = value.toString().split('-');

                date = new Date(
                    parseInt(dateParts[0]),
                    parseInt(dateParts[1]) -1, //Date counts months from 0
                    parseInt(dateParts[2])
                );
            } else {
                date = constructDate(value);
            }

            if (!date || _.isNaN(date.getTime())) { return; }

            return strftime(WORKAREA.config.date.format, date);
        },

        formatDateTime = function (date) {
            var localDate = constructDate(tryReformatDateStringWithTimezone(date));

            if (!date || _.isNaN(localDate.getTime())) { return; }

            return strftime(WORKAREA.config.date.format, localDate);
        },

        parseHoursFromDate = function (date) {
            var localDate = constructDate(tryReformatDateStringWithTimezone(date));

            if (!date || _.isNaN(localDate.getTime())) { return; }

            return strftime(WORKAREA.config.date.hours, localDate);
        },

        parseMinutesFromDate = function (date) {
            var localDate = constructDate(tryReformatDateStringWithTimezone(date));

            if (!date || _.isNaN(localDate.getTime())) { return; }

            return strftime(WORKAREA.config.date.minutes, localDate);
        },

        parseAmPmFromDate = function (date) {
            var localDate = constructDate(tryReformatDateStringWithTimezone(date));

            if (!date || _.isNaN(localDate.getTime())) { return; }

            return strftime(WORKAREA.config.date.ampm, localDate);
        };


    return {
        testDateFormat: testDateFormat,
        formatDate: formatDate,
        formatDateTime: formatDateTime,
        parseHoursFromDate: parseHoursFromDate,
        parseMinutesFromDate: parseMinutesFromDate,
        parseAmPmFromDate: parseAmPmFromDate
    };
}()));
