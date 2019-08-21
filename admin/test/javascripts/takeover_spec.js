(function () {
    'use strict';

    describe('WORKAREA.takeover', function () {
        beforeEach(function () {
            this.fixtures = fixture.load('takeover.html');
        });

        afterEach(function () {
            $('#takeover').remove();
        });

        describe('open', function () {
            it('allows only one takeover to be open at a time', function () {
                expect(_.partial(WORKAREA.takeover.open, 'foo')).to.not.throw(Error);
                expect(_.partial(WORKAREA.takeover.open, 'foo')).to.throw(Error);
            });

            it('binds a close action to the takeover close button', function () {
                WORKAREA.takeover.open('foo');
                expect(_.isEmpty($('#takeover'))).to.equal(false);
                $('#takeover_close_button').trigger('click');
                expect(_.isEmpty($('#takeover'))).to.equal(true);
            });

            it('toggles the takeover close button', function () {
                expect($('.header__menu-button--open').is(':visible')).to.equal(true);
                expect($('.header__menu-button--close').is(':visible')).to.equal(false);
                WORKAREA.takeover.open('foo');
                expect($('.header__menu-button--open').is(':visible')).to.equal(false);
                expect($('.header__menu-button--close').is(':visible')).to.equal(true);
            });

            it('opens a takeover', function () {
                WORKAREA.takeover.open('foo');
                expect($('#header').is('.header--takeover')).to.equal(true);
                expect($('#takeover').text()).to.include('foo');
            });

            it('returns the takeover collection', function () {
                var $takeover = WORKAREA.takeover.open('foo');
                expect($takeover.is('#takeover')).to.equal(true);
            });
        });

        describe('close', function () {
            beforeEach(function () {
                WORKAREA.takeover.open('foo');
            });

            it('toggles the takeover close buttons', function () {
                expect($('.header__menu-button--open').is(':visible')).to.equal(false);
                expect($('.header__menu-button--close').is(':visible')).to.equal(true);
                WORKAREA.takeover.close();
                expect($('.header__menu-button--open').is(':visible')).to.equal(true);
                expect($('.header__menu-button--close').is(':visible')).to.equal(false);
            });

            it('closes a takeover', function () {
                WORKAREA.takeover.close();
                expect($('#header').is('.header--takeover')).to.equal(false);
                expect(_.isEmpty($('#takeover'))).to.equal(true);
            });
        });

        describe('update', function () {
            it('replaces .takeover__content with some dom', function () {
                WORKAREA.takeover.open('<span>foo</span>');
                expect($('.takeover__content').text()).to.include('foo');

                WORKAREA.takeover.update('<span>bar</span>');
                expect($('.takeover__content').text()).to.include('bar');
            });
        });

        describe('current', function () {
            it('returns the current takeover', function () {
                WORKAREA.takeover.open('bar');
                expect(WORKAREA.takeover.current().text()).to.contain('bar');
            });
        });

        describe('reload', function () {
            it('errors if no takeover is open', function () {
                expect(WORKAREA.takeover.reload).to.throw(
                    Error, 'could not find an open takeover to reload'
                );
            });

            it('errors if no reloadUrl option is present', function () {
                WORKAREA.takeover.open('baz');

                expect(WORKAREA.takeover.reload).to.throw(
                    Error, 'missing `reloadUrl` option'
                );
            });
        });
    });
}());
