(function () {
    'use strict';

    describe('WORKAREA.popupButtons', function () {
        describe('getOptionString', function () {
            it('converts supplied config to window.open param string', function () {
                var markup = 'popup_button.html',
                    $fixture = $(fixture.load(markup, true)),

                    button = $('[data-popup-button]', $fixture)[0],
                    windowOpenParams;

                windowOpenParams = WORKAREA.popupButtons.getOptionString(button);

                expect(windowOpenParams).to.equal('width=200,height=300');
            });
        });
    });
}());
