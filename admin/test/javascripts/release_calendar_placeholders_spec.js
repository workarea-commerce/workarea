(function () {
    'use strict';

    describe('WORKAREA.releaseCalendarPlaceholders', function () {
        describe('init', function () {
            it('replaces a placeholder with a calendar', function () {
                var markup = 'release_calendar_placeholder.html',
                    $fixture = $(fixture.load(markup, true)),

                    server = sinon.fakeServer.create();

                server.respondWith('GET', '/foo/bar',
                    [200, { 'Content-Type': 'text/html; charset=utf-8' },
                    '<div class="calendar"></div>']
                );

                expect(_.isEmpty($('#placeholder'))).to.equal(false);

                WORKAREA.releaseCalendarPlaceholders.init($fixture);

                $(document).ajaxComplete(function () {
                    expect(_.isEmpty($('#placeholder'))).to.equal(true);

                    expect($('.calendar').length).to.equal(1);
                    expect(_.isEmpty($('.calendar'))).to.equal(false);
                });

                server.restore();
            });
        });

        describe('requestCalendar', function () {
            it('replaces the placeholder with a calendar', function () {
                var server = sinon.fakeServer.create();

                fixture.load('release_calendar_placeholder.html', true);

                server.respondWith('GET', '/foo/bar',
                    [200, { 'Content-Type': 'text/html; charset=utf-8' },
                    '<div class="calendar"></div>']
                );

                expect(_.isEmpty($('#placeholder'))).to.equal(false);

                WORKAREA.releaseCalendarPlaceholders.requestCalendar(
                    new Date(), $('#placeholder')[0], '/foo/bar'
                );

                $(document).ajaxComplete(function () {
                    expect(_.isEmpty($('#placeholder'))).to.equal(true);

                    expect($('.calendar').length).to.equal(1);
                    expect(_.isEmpty($('.calendar'))).to.equal(false);
                });

                server.restore();
            });
        });
    });
}());
