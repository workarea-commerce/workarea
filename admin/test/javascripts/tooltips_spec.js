(function () {
    'use strict';

    describe('WORKAREA.tooltips', function () {
        describe('init', function () {
            it('inits tooltipster on the link', function () {
                this.fixtures = fixture.load('tooltip.html', true);

                sinon.spy($.prototype, 'tooltipster');

                WORKAREA.tooltips.init($(this.fixtures));

                expect($.fn.tooltipster.calledOnce).to.equal(true);
                expect(_.includes($('#help-link').attr('class'), 'tooltipstered')).to.equal(true);
                expect(_.includes($('#tooltip').attr('class'), 'tooltip-content')).to.equal(true);

                $.fn.tooltipster.restore();
            });
        });

        describe('positionTooltip', function () {
            var instance = {}, helper = {}, position = {};

            beforeEach(function () {
                helper.geo = {};
                helper.geo.origin = {};
                helper.geo.window = {};
                helper.geo.window.scroll = { top: null, left: null };
                position.coord = { top: null, left: null };
            });

            it('displays the tooltip along the bottom edge of origin', function () {
                var result;

                position.size = { width: 300 }; // tooltip width
                helper.geo.window.size = { width: 1000 }; // window width
                helper.geo.origin.offset = { left: 100, bottom: 200 }; // origin offset

                result = WORKAREA.tooltips.positionTooltip(instance, helper, position);

                expect(result.coord.top).to.equal(200);

                helper.geo.origin.offset.left = 900; // origin too close to right edge

                result = WORKAREA.tooltips.positionTooltip(instance, helper, position);

                expect(result.coord.top).to.equal(200);
                expect(result.coord.left).to.equal(700); // window width - tooltip width
            });
        });
    });
}());
