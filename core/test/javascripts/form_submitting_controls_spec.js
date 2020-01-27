//= require workarea/core/modules/environment
//= require workarea/core/modules/url
//= require workarea/core/modules/form_submitting_controls

(function () {
    'use strict';

    describe('WORKAREA.formSubmittingControls', function () {
        describe( 'init', function () {
            it('submits a form on change', function (done) {
                this.fixture = fixture.load('form_submitting_controls.html');

                WORKAREA.formSubmittingControls.init($(this.fixture));

                $('select[data-form-submitting-control]').val('3').trigger('change');

                $('#form-submitting-controls').on('submit', function (event) {
                    event.preventDefault();
                    done();
                });
            });

            it('submits a form on input', function (done) {
                this.fixture = fixture.load('form_submitting_controls.html');

                WORKAREA.formSubmittingControls.init($(this.fixture));

                $('input[data-form-submitting-control]').val('foo').trigger('input');

                $('#form-submitting-controls').on('submit', function (event) {
                    event.preventDefault();
                    done();
                });
            });
        });
    });
}());
