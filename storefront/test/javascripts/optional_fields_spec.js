(function () {
    'use strict';

    describe('WORKAREA.optionalFields', function () {
        describe('init', function () {
            it('toggles normal DOM', function () {
                this.fixtures = fixture.load('optional_fields.html');

                WORKAREA.optionalFields.init($(this.fixtures));

                expect($('button.link').text()).to.contain('foobar');

                $('button.link').trigger('click');

                expect(_.isEmpty($('button.link'))).to.be.true;
                expect(_.isEmpty($('.hidden-if-js-enabled'))).to.be.true;
            });
        });
    });
}());
