(function () {
    'use strict';

    describe('WORKAREA.backToTopButton', function () {
        describe('init', function () {
            beforeEach(function () {
                this.fixtures = fixture.load('back_to_top_button.html');
                WORKAREA.backToTopButton.init($(this.fixtures));
            });

            afterEach(function () {
                $('#back-to-top-button').remove();
            });

            it('injects a button', function () {
                expect(_.isEmpty($('#back-to-top-button'))).to.equal(false);
            });

            it('saves a waypoint instance to the element', function () {
                var $trigger = $('[data-back-to-top-button]'),
                    waypoint = $trigger.data('backToTopWaypoint');

                expect(waypoint).to.be.an('object');
                expect(waypoint.element).to.equal($trigger[0]);
                expect(waypoint.key).to.include('waypoint');
            });

            it('handles the visibility of the button', function () {
                var $trigger = $('[data-back-to-top-button]'),
                    waypoint = $trigger.data('backToTopWaypoint');

                waypoint.callback('down');
                expect(_.isEmpty($('.back-to-top-button--visible'))).to.equal(false);

                waypoint.callback('up');
                expect(_.isEmpty($('.back-to-top-button--visible'))).to.equal(true);
            });
        });
    });
}());

