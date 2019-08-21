(function () {
    'use strict';

    describe('WORKAREA.forms', function() {
        describe('init', function () {
            it('displays errors if input is invalid', function () {
                this.fixtures = fixture.load('form.html');

                WORKAREA.forms.init($(this.fixtures));

                expect(
                    _.isEmpty($('#required_property .value__error'))
                ).to.equal(true);

                $('form').trigger('submit');

                expect(
                    _.isEmpty($('#required_property .value__error'))
                ).to.equal(false);
                expect(
                    $('#required_property .value__error').is('label')
                ).to.equal(true);
            });

            it('adds invalid modifier for property on blur', function () {
                this.fixtures = fixture.load('form.html');

                WORKAREA.forms.init($(this.fixtures));

                $('#required_input').trigger('focus');
                $('#text_box').trigger('focus');

                expect(
                    $('#required_property').is('.property--invalid')
                ).to.equal(true);

                $('#required_input').trigger('focus').val('Foo');
                $('#text_box').trigger('focus');

                expect(
                    $('#required_property').is('.property--invalid')
                ).to.equal(false);
            });

            it('toggles valid/invalid modifier for text-box on blur', function () {
                this.fixtures = fixture.load('form.html');

                WORKAREA.forms.init($(this.fixtures));

                $('#text_box').trigger('focus');
                $('#required_input').trigger('focus');

                expect($('#text_box').is('.text-box--invalid')).to.equal(true);

                $('#text_box').trigger('focus').val('Foo');
                $('#required_input').trigger('focus');

                expect($('#text_box').is('.text-box--valid')).to.equal(true);

                $('#text_box').trigger('focus').val('');
                $('#required_input').trigger('focus');

                expect($('#text_box').is('.text-box--valid')).to.equal(false);
            });

            it('invalidates properties containing errors on-load', function () {
                this.fixtures = fixture.load('form.html');

                WORKAREA.forms.init($(this.fixtures));

                expect($('#preexisting_error').is('.property--invalid')).to.be.true;
            });

            it('removes visible errors when input becomes valid', function () {
                this.fixtures = fixture.load('form.html');

                WORKAREA.forms.init($(this.fixtures));

                $('#text_box_with_error').val('foobar').trigger('blur');

                expect(_.isEmpty($('#preexisting_error .value__error'))).to.be.true;
            });
        });
    });
}());
