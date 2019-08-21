/**
 * Responsible for the fetching and replacement of a calendar on the Release
 * Dashboard in the admin.
 *
 * @namespace WORKAREA.releaseCalendarPlaceholders
 */
WORKAREA.registerModule('releaseCalendarPlaceholders', (function () {
    'use strict';

    var displayCalendar = function (placeholder, view) {
            var $calendar = $('.calendar', view);

            $(placeholder).replaceWith($calendar);

            WORKAREA.initModules($calendar);
        },

        now = new Date(),

        standardTimezoneOffset = function() {
            var jan = new Date(now.getFullYear(), 0, 1).getTimezoneOffset(),
                jul = new Date(now.getFullYear(), 6, 1).getTimezoneOffset();

            return Math.max(jan, jul);
        },

        isDSTObserved = now.getTimezoneOffset() < standardTimezoneOffset(),

        /**
         * Makes the AJAX request for a new calendar based on a supplied time.
         * When the promise resolves the supplied placeholder element is
         * replaced by the server's response.
         *
         * @method
         * @name requestCalendar
         * @memberof WORKAREA.releaseCalendarPlaceholders
         * @param {String} startDate - strftime `%Y-%m-%d` for the desired date
         * @param {element} placeholder - the DOM element to be replaced by the
         *   fetched calendar
         * @param {string} endpoint - the endpoint for the AJAX request
         */
        requestCalendar = function (startDate, placeholder, endpoint) {
            var timeOffset = parseInt(strftime('%z', new Date()));

            if (isDSTObserved) {
                timeOffset = timeOffset - 100;
            }

            $.get(endpoint, {
                start_date: startDate,
                time_offset: timeOffset
            })
            .done(_.partial(displayCalendar, placeholder))
            .fail(
                _.partial(
                    WORKAREA.messages.insertMessage,
                    I18n.t('workarea.admin.js.release_calendar_placeholder.error_message'),
                    'error'
                )
            );
        },

        initCalendar = function (index, placeholder) {
            var today = new Date(),
                endpoint = $(placeholder).data('releaseCalendarPlaceholder');

            requestCalendar(today, placeholder, endpoint);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.releaseCalendarPlaceholders
         */
        init = function ($scope) {
            $('[data-release-calendar-placeholder]', $scope).each(initCalendar);
        };

    return {
        init: init,
        requestCalendar: requestCalendar
    };
}()));
