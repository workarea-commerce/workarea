//= require workarea/core/modules/string

(function () {
    'use strict';

    describe('WORKAREA.string', function () {
        describe('titleize', function () {
            it('titleizes a given string', function () {
                expect(WORKAREA.string.titleize('foo   ')).to.equal('Foo');
                expect(WORKAREA.string.titleize('BAR')).to.equal('Bar');
                expect(WORKAREA.string.titleize('fOoBaR')).to.equal('Foobar');
            });
        });

        describe('pluralize', function () {
            it('returns a custom pluralized string', function () {
                expect(WORKAREA.string.pluralize(2, 'baz', 'bazes')).to.equal('bazes');
            });

            it('returns a simple pluralized string', function () {
                expect(WORKAREA.string.pluralize(2, 'bar')).to.equal('bars');
            });

            it('returns an unpluralized string', function () {
                expect(WORKAREA.string.pluralize(1, 'foo')).to.equal('foo');
            });
        });

        describe('dasherize', function () {
            it('converts to lowercase', function () {
                expect(WORKAREA.string.dasherize('FOO')).to.equal('foo');
            });

            it('replaces spaces with dashes', function () {
                expect(WORKAREA.string.dasherize('foo bar')).to.equal('foo-bar');
                expect(WORKAREA.string.dasherize('foo      bar')).to.equal('foo-bar');
                expect(WORKAREA.string.dasherize('foo bar baz')).to.equal('foo-bar-baz');
            });
        });
    });
}());
