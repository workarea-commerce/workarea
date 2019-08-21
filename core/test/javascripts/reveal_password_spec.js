//= require workarea/core/templates/reveal_password_button
//= require workarea/core/modules/reveal_password

(function () {
    'use strict';

    describe('WORKAREA.revealPassword', function () {
        describe('init', function () {
            it('displays a password, on click', function () {
                this.fixtures = fixture.load('reveal_password.html');

                WORKAREA.revealPassword.init($(this.fixtures));

                $('[data-reveal-password]').not('.hidden').trigger('click');
                expect($('input').attr('type')).to.equal('text');

                $('[data-reveal-password]').not('.hidden').trigger('click');
                expect($('input').attr('type')).to.equal('password');
            });
        });
    });
}());
