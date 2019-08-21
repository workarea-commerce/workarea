(function () {
    'use strict';

    describe('WORKAREA.contentBlocks', function () {
        describe('init', function () {
            beforeEach(function () {
                this.fixtures = fixture.load('content_block.html');
            });

            afterEach(function () {
                WORKAREA.takeover.close();
            });

            it('activates when clicked', function () {
                WORKAREA.contentBlocks.init($(this.fixtures));

                $('.content-block').addClass('content-block--inactive');

                $('.content-block__overlay').trigger('click');

                expect(_.isEmpty('.content-block--active')).to.equal(false);
            });
        });

        describe('activateBlock', function() {
            it('activates the content block', function() {
                var $fixture = $(fixture.load('content_block.html')),
                    $block = $('.content-block', $fixture).first();

                WORKAREA.contentBlocks.activateBlock($block);

                expect(_.isEmpty($('.content-block--active'))).to.equal(false);
            });
        });

        describe('deactivateBlock', function() {
            it('deactivates the content block', function() {
                var $fixture = $(fixture.load('content_block.html')),
                    $block = $('.content-block', $fixture).first();

                WORKAREA.contentBlocks.deactivateBlock($block);

                expect(_.isEmpty($('.content-block--active'))).to.equal(true);
            });
        });
    });
}());
