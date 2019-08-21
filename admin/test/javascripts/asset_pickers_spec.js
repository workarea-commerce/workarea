(function () {
    'use strict';

    describe('WORKAREA.assetPickers', function () {
        describe('init', function () {
            beforeEach(function () {
                this.fixtures = fixture.load('asset_picker.html');
                WORKAREA.assetPickers.init($(this.fixtures));
            });

            afterEach(function () {
                WORKAREA.takeover.close();
            });

            it('submits forms async', function () {
                var server = sinon.fakeServer.create();

                server.respondWith('GET', '/foo',
                [200, { 'Content-Type': 'text/html; charset=utf-8' }, '<span>FORM</span>']);

                $('#form').trigger('submit');

                server.respond();

                expect($('#takeover').text().trim()).to.equal('FORM');

                server.restore();
            });

            it('retrieves link href async', function () {
                var server = sinon.fakeServer.create();

                server.respondWith('GET', '/bar',
                [200, { 'Content-Type': 'text/html; charset=utf-8' }, '<span>LINK</span>']);

                $('#link').trigger('click');

                server.respond();

                expect($('#takeover').text().trim()).to.equal('LINK');

                server.restore();
            });

            it('announces asset url when asset is inserted', function (done) {
                $(window).on('assetPickers:insert', function (event, data) {
                    expect(data.id).to.equal('foo');
                    expect(data.name).to.equal('Foo Asset');
                    done();
                });

                $('#summary').trigger('click');
            });
        });
    });
}());
