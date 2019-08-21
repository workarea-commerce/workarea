/**
 * Handles aspects of the Calendar's UI, such as the vertical positioning of
 * release elements within the calendar & the adjustment of the heigh of each
 * calendar day based on the tallest day. Also ensures that the Next and Back
 * buttons on the calendar are handled via AJAX.
 *
 * @namespace WORKAREA.calendars
 */
WORKAREA.registerModule('calendars', (function () {
    'use strict';

    var countReleases = function (container) {
            return $('.calendar__release', container).length;
        },

        daysWithReleases = function (calendar) {
            return $('td', calendar).has('.calendar__release');
        },

        compensatePosition = function (top, release) {
            return top - $(release).position().top;
        },

        getReleaseOnPrevDay = function (releaseId, $prev) {
            var $releases = $('[data-calendar-release-id]', $prev);

            return $releases.filter(function (index, release) {
                return $(release).data('calendarReleaseId') === releaseId;
            });
        },

        resetCalendar = function (event) {
            var calendar = event.delegateTarget,
                today = new Date(),
                endpoint = WORKAREA.routes.admin.releasesPath();

            event.preventDefault();

            WORKAREA.releaseCalendarPlaceholders.requestCalendar(
                today, calendar, endpoint
            );
        },

        requestNewCalendar = function (event) {
            var calendar = event.delegateTarget,
                parsedHref = WORKAREA.url.parse(event.currentTarget.href),
                startDate = parsedHref.queryKey.start_date,
                endpoint = parsedHref.path;

            event.preventDefault();

            WORKAREA.releaseCalendarPlaceholders.requestCalendar(
                startDate, calendar, endpoint
            );
        },

        showTodayButton = function (calendar) {
            var $todayButton = $('.calendar__today-button', calendar);

            if (_.isEmpty($('.calendar__day--today', calendar))) {
                $todayButton.addClass('calendar__today-button--active');
            } else {
                $todayButton.removeClass('calendar__today-button--active');
            }
        },

        adjustHeightOfCell = function (top, release) {

            var topInteger = parseInt(top);

            if (topInteger > 0) {
                var currentHeight = $(release).closest('.calendar__day').css('height'),
                    newHeight = parseInt(currentHeight) + topInteger;

                $(release).closest('.calendar__day').css({height: newHeight + 'px'});
            }
        },

        adjustRelease = function ($prev, index, release) {
            var releaseId = $(release).data('calendarReleaseId'),
                $prevRelease = getReleaseOnPrevDay(releaseId, $prev),
                top,
                $prevReleaseOnDay = $(release).prev('.calendar__release');

            if (_.isEmpty($prevRelease)) {
                top =  $prevReleaseOnDay.css('top');
                adjustHeightOfCell(top, release);
            } else {
                top = compensatePosition($prevRelease.position().top, release);
                top = top || $prevRelease.css('marginTop');
            }

            $(release).css({ position: 'relative', top: top });
        },

        findReleasesToAdjust = function (index, day) {
            var $day = $(day),
                $prev = $(day).prev(),
                releasesOnDay = countReleases($day);

            $(day).data('releasesOnDay', {
                $day: $day,
                releaseCount: releasesOnDay
            });

            $('.calendar__release', $day).each(_.partial(adjustRelease, $prev));
        },

        initCalendar = function (index, calendar) {
            daysWithReleases(calendar).each(findReleasesToAdjust);
            showTodayButton(calendar);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.calendars
         */
        init = function ($scope) {
            $('.calendar', $scope)
                .addBack('.calendar')
                .on('click', '.calendar__control', requestNewCalendar)
                .on('click', '[data-calendar-today-button]', resetCalendar)
                .each(initCalendar);
        };

    return {
        init: init
    };
}()));
