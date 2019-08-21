//= require workarea/core/modules/date

(function () {
    'use strict';

    describe('WORKAREA.date', function () {
        describe('testDateFormat', function () {
            it('returns true when a correctly formatted date is passed', function () {
                expect(WORKAREA.date.testDateFormat('2017-03-09')).to.equal(true);
            });

            it('returns false when an incorrectly formatted date is passed', function () {
                expect(WORKAREA.date.testDateFormat('03-09-2017')).to.equal(false);
                expect(WORKAREA.date.testDateFormat('not-a-date')).to.equal(false);
            });

            it('returns false when a date object is passed', function () {
                var d = new Date('Thu Mar 09 2017 09:04:20');
                expect(WORKAREA.date.testDateFormat(d)).to.equal(false);
            });
        });

        describe('formatDate', function () {
            it('Given a date, returns a full date time for midnight the same day', function () {
                var formatted = WORKAREA.date.formatDate('2017-03-09');
                expect(_.startsWith(formatted, '2017-03-09 12:00 am')).to.equal(true);
            });

            it('Given a date time returns a formatted date time', function () {
                var d = new Date('Thu Mar 09 2017 09:04:20'),
                    formatted = WORKAREA.date.formatDate(d);

                expect(_.startsWith(formatted, '2017-03-09 09:04 am')).to.equal(true);
            });
        });

        describe('formatDateTime', function () {
            it('returns an Object representing the parts of a URL', function () {
                var d = new Date('Thu Mar 09 2017 09:04:20'),
                    formatted = WORKAREA.date.formatDateTime(d);

                expect(_.startsWith(formatted, '2017-03-09 09:04 am')).to.equal(true);
            });

            it('can handle a string with timezone from Rails', function () {
                var testDate = new Date(),
                    railsFormatted = strftime('%Y-%m-%d %H:%M:%S %z', testDate),
                    result = WORKAREA.date.formatDateTime(railsFormatted),
                    jsFormatted = strftime('%Y-%m-%d %I:%M %P', testDate);

                expect(_.startsWith(result, jsFormatted)).to.equal(true);
            });
        });

        describe('parseHoursFromDate', function () {
            it('returns 0 padded hours value of Date', function () {
                var d = new Date('Thu Mar 09 2017 09:04:20');
                expect(WORKAREA.date.parseHoursFromDate(d)).to.equal('09');
            });

            it('returns hours in 12 clock format', function () {
                var d = new Date('Thu Mar 09 2017 19:04:20');
                expect(WORKAREA.date.parseHoursFromDate(d)).to.equal('07');
            });

            it('can handle a string with timezone from Rails', function () {
                var testDate = new Date(),
                    railsFormatted = strftime('%Y-%m-%d %H:%M:%S %z', testDate),
                    expected = strftime('%I', testDate);

                expect(WORKAREA.date.parseHoursFromDate(railsFormatted)).to.equal(expected);
            });
        });

        describe('parseMinutesFromDate', function () {
            it('returns 0 padded minutes value of Date', function () {
                var d = new Date('Thu Mar 09 2017 09:04:20');
                expect(WORKAREA.date.parseMinutesFromDate(d)).to.equal('04');
            });

            it('can handle a string with timezone from Rails', function () {
                var value = '2017-10-29 12:02:00 -0400';
                expect(WORKAREA.date.parseMinutesFromDate(value)).to.equal('02');
            });
        });

        describe('parseAmPmFromDate', function () {
            it('returns am or pm depending on the date passed in', function () {
                var d = new Date('Thu Mar 09 2017 19:04:20');
                expect(WORKAREA.date.parseAmPmFromDate(d)).to.equal('pm');
            });

            it('can handle a string with timezone from Rails', function () {
                var testDate = new Date(),
                    railsFormatted = strftime('%Y-%m-%d %H:%M:%S %z', testDate),
                    expected = strftime('%P', testDate);

                expect(WORKAREA.date.parseAmPmFromDate(railsFormatted)).to.equal(expected);
            });
        });
    });
}());
