(function () {
    'use strict';

    describe('WORKAREA.primaryNav', function () {
        describe('init', function () {
            afterEach(function () {
                WORKAREA.takeover.close();
            });

            it('opens content in a takeover, on click', function () {
                this.fixtures = fixture.load('primary_nav.html');

                WORKAREA.primaryNav.init($(this.fixtures));

                $('#link').trigger('click');

                expect(_.isEmpty($('#takeover'))).to.equal(false);
                expect($('#takeover').text()).to.include('Nav Content');
            });
        });
    });
}());
