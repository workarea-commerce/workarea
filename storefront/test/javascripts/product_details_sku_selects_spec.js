(function () {
    'use strict';

    describe('WORKAREA.productDetailsSkuSelects', function () {
        describe('init', function () {
            var server;

            describe('with option sku selects', function() {

                beforeEach(function () {
                    this.fixtures = fixture.load('product_details_sku_select.html');

                    server = sinon.fakeServer.create();
                    server.respondWith(
                        'GET',
                        WORKAREA.routes.storefront.detailsProductPath(
                            { id: 'foo-product', via: 'foo_via', sku: 'bar', _options: true }
                        ),
                        [200, { 'Content-Type': 'text/html' }, '<div class="product-details">SUCCESS</div>']
                    );
                    server.respondWith(
                        'GET',
                        WORKAREA.routes.storefront.detailsProductPath(
                            { id: 'foo-product', via: 'foo_via', sku: 'foo', _options: true }
                        ),
                        [200, { 'Content-Type': 'text/html' }, '<div class="product-details">BLUE SUCCESS</div>']
                    );
                });

                afterEach(function () {
                    var cleanUrl = window.location.href.replace('sku=bar', '');
                    window.history.replaceState(null, null, cleanUrl);

                    // destroy all open dialogs
                    _.forEach(WORKAREA.dialog.all(), function (dialog) {
                        $(dialog).dialog('destroy');
                    });

                    server.restore();
                });

                it('passes all details in the url when requesting a new variant', function () {
                    WORKAREA.productDetailsSkuSelects.init($(this.fixtures));

                    $('[data-product-details-sku-select]', this.fixtures)
                        .val('foo').trigger('change');

                    server.respond();

                    expect($('.product-details', this.fixtures).html()).to.include(
                        'BLUE SUCCESS'
                    );
                });

                it('replaces the .product-details container with server response on change', function () {
                    WORKAREA.productDetailsSkuSelects.init($(this.fixtures));

                    $('[data-product-details-sku-select]', this.fixtures)
                        .val('bar').trigger('change');

                    server.respond();

                    expect($('.product-details', this.fixtures).html()).to.include(
                        'SUCCESS'
                    );
                });

                it('replaces history state if not in dialog', function () {
                    WORKAREA.productDetailsSkuSelects.init($(this.fixtures));

                    $('[data-product-details-sku-select]')
                        .val('bar')
                        .trigger('change');

                    server.respond();
                    expect(window.location.href).to.include('sku=bar');
                });

                it('does not change url when multiple product-details exist', function () {
                    $(this.fixtures).append('<div class="product-details" />');
                    WORKAREA.productDetailsSkuSelects.init($(this.fixtures));

                    $('[data-product-details-sku-select]')
                        .val('bar')
                        .trigger('change');

                    server.respond();
                    expect(window.location.href).to.not.include('sku=bar');
                });

                it('does not change url when product-details nested in dialog', function () {
                    WORKAREA.dialog.create(this.fixtures);
                    WORKAREA.productDetailsSkuSelects.init($(this.fixtures));

                    $('[data-product-details-sku-select]')
                        .val('bar')
                        .trigger('change');

                    server.respond();
                    expect(window.location.href).to.not.include('sku=bar');
                });
            });

            describe('with no colors to select', function() {
                var server;

                beforeEach(function () {
                    this.fixtures = fixture.load('product_details_sku_select_without_sku_option_details.html');

                    server = sinon.fakeServer.create();
                    server.respondWith(
                        'GET',
                        WORKAREA.routes.storefront.detailsProductPath(
                            { id: 'foo-product', sku: 'bar', _options: true }
                        ),
                        [200, { 'Content-Type': 'text/html' }, '<div class="product-details">SUCCESS</div>']
                    );
                    server.respondWith(
                        'GET',
                        WORKAREA.routes.storefront.detailsProductPath(
                            { id: 'foo-product', sku: 'foo', _options: true }
                        ),
                        [200, { 'Content-Type': 'text/html' }, '<div class="product-details">BLUE SUCCESS</div>']
                    );
                });

                afterEach(function () {
                    var cleanUrl = window.location.href.replace('sku=bar', '');
                    window.history.replaceState(null, null, cleanUrl);

                    // destroy all open dialogs
                    _.forEach(WORKAREA.dialog.all(), function (dialog) {
                        $(dialog).dialog('destroy');
                    });

                    server.restore();
                });

                it('still works without color variants', function() {
                    WORKAREA.productDetailsSkuSelects.init($(this.fixtures));

                    $('[data-product-details-sku-select]', this.fixtures)
                        .val('foo').trigger('change');

                    server.respond();

                    expect($('.product-details', this.fixtures).html()).to.include(
                        'SUCCESS'
                    );
                });
            });
        });
    });
}());
