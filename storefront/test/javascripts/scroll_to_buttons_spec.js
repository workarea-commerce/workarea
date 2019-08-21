(function () {
    'use strict';

    describe('WORKAREA.scrollToButtons', function () {
        beforeEach(function () {
            sinon.spy(WORKAREA.scrollToButtons, 'scrollToElement');
            WORKAREA.initModules(
                $(fixture.load('scroll_to_element.html.haml', true))
            );
        });

        afterEach(function () {
            WORKAREA.scrollToButtons.scrollToElement.restore();
        });

        describe('init', function () {
            it('scrolls to the element on the page when clicked', function () {
                $('.pdp .reviews-link').click();

                expect(WORKAREA.scrollToButtons.scrollToElement.calledOnce).to.equal(true);
            });

            it('scrolls within a dialog', function () {
                $('.ui-dialog .returns-link').click();

                expect(WORKAREA.scrollToButtons.scrollToElement)
                    .to.have.been.called;
            });

            it('prevents scrolling outside of dialog', function () {
                $('.ui-dialog .reviews-link').click();

                expect(WORKAREA.scrollToButtons.scrollToElement)
                    .not.to.have.been.called;
            });

            it('prevents scrolling when target not found', function () {
                $('.ui-dialog .external-link').click();

                expect(WORKAREA.scrollToButtons.scrollToElement)
                    .not.to.have.been.called;
            });

        });
    });
}());
