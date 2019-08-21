//= require workarea/core/modules/deletion_forms

(function () {
    'use strict';

    describe('WORKAREA.deletionForms', function () {
        describe('init', function () {
            it('ignores forms with the data attribute to disable confirmation', function () {
                var $fixture = $(fixture.load('deletion_forms.html', true));

                // prevent the form from submitting when we trigger it later
                $fixture
                    .find('form')
                    .on('submit', function (e) { e.preventDefault(); });

                WORKAREA.deletionForms.init($fixture);
                sinon.spy(window, 'confirm');

                $('#form-without-confirmation').trigger('submit');
                expect(window.confirm.getCall(0)).to.equal(null);

                window.confirm.restore();
            });
        });
    });
}());

