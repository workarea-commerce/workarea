(function () {
    'use strict';

    describe('WORKAREA.lazyImages', function () {
        beforeEach(function () {
            sinon.spy(WORKAREA.lazyImages, 'lazyLoad');
            sinon.spy(WORKAREA.lazyImages, 'loadImage');
        });

        afterEach(function () {
            WORKAREA.lazyImages.lazyLoad.restore();
            WORKAREA.lazyImages.loadImage.restore();
        });

        it('only initializes when lazy images are found', function () {
            this.fixture = fixture.set('<img />');

            WORKAREA.lazyImages.init($(this.fixture));

            expect(WORKAREA.lazyImages.lazyLoad.notCalled);

            this.fixture = fixture.set('<img data-lazy-image />');

            WORKAREA.lazyImages.init($(this.fixture));

            expect(WORKAREA.lazyImages.lazyLoad.calledOnce);
        });

        it('only loads images in viewport', function () {
            this.fixture = fixture.set(
                '<img data-lazy-image />' +
                '<img data-lazy-image style="position:absolute;left: -999px" />'
            );

            WORKAREA.lazyImages.init($(this.fixture));

            expect(WORKAREA.lazyImages.lazyLoad.calledOnce);
        });
    });
}());

