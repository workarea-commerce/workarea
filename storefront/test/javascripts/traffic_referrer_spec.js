(function () {
    'use strict';

    describe('WORKAREA.trafficReferrer', function () {
        describe('setCookie', function () {
            beforeEach(function () {
                WORKAREA.cookie.destroy('workarea_referrer');
            });

            it('sets a cookie', function () {
                WORKAREA.trafficReferrer.setReferrer('http://workarea.com');

                WORKAREA.trafficReferrer.setCookie();
                expect(WORKAREA.cookie.read('workarea_referrer')).to.equal('http://workarea.com');
            });

            it('does not set a cookie when host matches referrer', function () {
                WORKAREA.trafficReferrer.setReferrer(window.location.origin);

                WORKAREA.trafficReferrer.setCookie();
                expect(WORKAREA.cookie.read('workarea_referrer')).to.equal(null);
            });

            it('does not set cookie when cookie is already set', function () {
                WORKAREA.cookie.create('workarea_referrer', 'http://example.com');
                WORKAREA.trafficReferrer.setReferrer('http://workarea.com');

                WORKAREA.trafficReferrer.setCookie();
                expect(WORKAREA.cookie.read('workarea_referrer')).to.equal('http://example.com');
            });
        });
    });
}());
