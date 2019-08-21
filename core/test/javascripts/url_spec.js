//= require workarea/core/modules/url

(function () {
    'use strict';

    describe('WORKAREA.url', function () {
        describe('replaceQuery', function () {
            it('replaces entire query string', function () {
                expect(WORKAREA.url.replaceQuery('http://foo.com?bar=baz&baz=qux', 'foo=bar')).to.equal('http://foo.com?foo=bar');
            });
        });

        describe('removeQuery', function () {
            it('removes entire query string', function () {
                expect(WORKAREA.url.removeQuery('http://foo.com?foo=bar')).to.equal('http://foo.com');
            });
        });

        describe('addQuery', function () {
            it('adds a query to a query-less url', function () {
                expect(WORKAREA.url.addQuery('http://foo.com', 'foo=bar')).to.equal('http://foo.com?foo=bar');
            });
        });

        describe('updateParams', function () {
            it('changes the value of a specified query param', function () {
                expect(WORKAREA.url.updateParams('http://foo.com?foo=bar', {'foo': 'baz'})).to.equal('http://foo.com?foo=baz');
            });

            it('updates the value of multiple query params', function () {
                expect(WORKAREA.url.updateParams('http://foo.com?foo=bar&baz=qux', {'foo':'qux', 'baz': 'bar'})).to.equal('http://foo.com?foo=qux&baz=bar');
            });

            it('does not change unspecified params', function () {
                expect(WORKAREA.url.updateParams('http://foo.com?foo=bar&baz=qux', {'foo': 'baz'})).to.equal('http://foo.com?foo=baz&baz=qux');
            });

            it('encodes array params', function () {
                expect(WORKAREA.url.updateParams('http://foo.com?foo[]=bar&foo[]=baz', {'foo': ['qux', 'chud']})).to.equal(window.encodeURI('http://foo.com?foo[]=qux&foo[]=chud'));
            });
        });

        describe('parse', function () {
            it('returns an Object representing the parts of a URL', function () {
                var domain = 'https://user:pass@foo.com:123',
                    path = '/bar/baz.jpg',
                    query = '?foo=bar&bar=baz&qux[]=quux&qux[]=chud#thud',
                    url = domain + path + query,
                    parsedUrl = WORKAREA.url.parse(url);

                expect(parsedUrl.source).to.equal(url);
                expect(parsedUrl.authority).to.equal('user:pass@foo.com:123');
                expect(parsedUrl.protocol).to.equal('https');
                expect(parsedUrl.userInfo).to.equal('user:pass');
                expect(parsedUrl.user).to.equal('user');
                expect(parsedUrl.password).to.equal('pass');
                expect(parsedUrl.host).to.equal('foo.com');
                expect(parsedUrl.port).to.equal('123');
                expect(parsedUrl.relative).to.equal(path + query);
                expect(parsedUrl.path).to.equal(path);
                expect(parsedUrl.directory).to.equal('/bar/');
                expect(parsedUrl.file).to.equal('baz.jpg');
                expect(parsedUrl.query).to.equal('foo=bar&bar=baz&qux[]=quux&qux[]=chud');
                expect(parsedUrl.queryKey.foo).to.equal('bar');
                expect(parsedUrl.queryKey.bar).to.equal('baz');
                expect(parsedUrl.queryKey.qux).to.be.an('Array');
                expect(parsedUrl.queryKey.qux.length).to.equal(2);
                expect(parsedUrl.queryKey.qux[0]).to.equal('quux');
                expect(parsedUrl.queryKey.qux[1]).to.equal('chud');
                expect(parsedUrl.anchor).to.equal('thud');
            });
        });
    });
}());
