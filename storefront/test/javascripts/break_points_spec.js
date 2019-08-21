(function () {
    'use strict';

    describe('WORKAREA.breakPoints', function () {
        describe('currentMatches', function () {
            it('returns an array', function () {
                expect(WORKAREA.breakPoints.currentMatches).to.be.instanceof(Array);
            });
        });

        describe('currentlyLessThan', function () {
            var config = WORKAREA.config.storefrontBreakPoints;
            before(function () {
                WORKAREA.config.storefrontBreakPoints.sizes = {
                    small: 320,
                    medium: 760,
                    wide: 960,
                    x_wide: 1160,
                    test: 999999
                };

                WORKAREA.breakPoints.createBreakPoints();
            });

            after(function(){
                WORKAREA.config.storefrontBreakPoints = config;
            });

            it('returns correct boolean value depending on current breakpoint', function () {
                expect(WORKAREA.breakPoints.currentlyLessThan('small')).to.be.false;
                expect(WORKAREA.breakPoints.currentlyLessThan('test')).to.be.true;
            });

            it('returns false unless a valid breakpoint name is provided', function () {
                expect(WORKAREA.breakPoints.currentlyLessThan('foo')).to.be.false;
                expect(WORKAREA.breakPoints.currentlyLessThan(1)).to.be.false;
                expect(WORKAREA.breakPoints.currentlyLessThan(undefined)).to.be.false;
            });
        });
    });
}());
