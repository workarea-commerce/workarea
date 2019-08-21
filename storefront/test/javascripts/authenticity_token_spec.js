(function () {
    'use strict';

    describe('WORKAREA.authenticityToken', function () {
        it('appends authenticity token within jQuery.ajax#beforeSend', function() {
            this.fixtures = fixture.load('authenticity_token.html', false);
            WORKAREA.initModules($(this.fixtures));

            $.get('/')
                .then(function(response, event, xhr) {
                    expect(xhr.getResponseHeader('X-CSRF-Token')).to.equal('foo');
                })
                .done();
        });

        describe('init', function() {
            it('appends user authenticity token to forms', function() {
                WORKAREA.authenticityToken.init($(this.fixtures));

                var $input = $('form > input[type="hidden"][name="authenticity_token"]');

                expect($input).not.to.be.empty;
            });
        });
    });
}());
