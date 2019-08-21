//= require workarea/core/modules/cookie

(function () {
    'use strict';

    describe('WORKAREA.cookie', function () {
        describe('create', function () {
            it('creates a cookie with a given name and value', function () {
                WORKAREA.cookie.create('foo', 'bar', 7);

                expect(_.includes(document.cookie, 'foo=bar')).to.equal(true);
            });
        });

        describe('destroy', function () {
            it('destroys a cookie with a given name', function () {
                WORKAREA.cookie.create('foo', 'bar', 7);
                WORKAREA.cookie.destroy('foo');

                expect(_.includes(document.cookie, 'foo=bar')).to.equal(false);
            });
        });

        describe('read', function () {
            it('reads the cookie', function () {
                document.cookie = 'foo=bar';
                expect(WORKAREA.cookie.read('foo')).to.equal('bar');
            });

            it('reads a url with query params from the cookie', function() {
                document.cookie = 'baz=http://bat.com/?q=hello';

                expect(WORKAREA.cookie.read('baz')).to.equal('http://bat.com/?q=hello');
            });
        });
    });
}());
