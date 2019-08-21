(function () {
    'use strict';

    describe('WORKAREA.analytics', function () {
        describe('registerAdapter', function () {
            it('adds to callbacks', function () {
                WORKAREA.analytics.registerAdapter('foo', function () {
                    return { test: $.noop };
                });

                WORKAREA.analytics.registerAdapter('bar', function () {
                    return { test: $.noop };
                });

                expect(WORKAREA.analytics.callbacks.test).to.have.length(2);

                expect(WORKAREA.analytics.callbacks.test[0]).to.be.a('function');
                expect(WORKAREA.analytics.callbacks.test[1]).to.be.a('function');
            });
        });

        describe('fireCallback', function () {
            it('runs the callbacks for the event with data', function () {
                var foo = null,
                    bar = null;

                WORKAREA.analytics.registerAdapter('foo', function () {
                    return { test: function (data) { foo = data; } };
                });

                WORKAREA.analytics.registerAdapter('bar', function () {
                    return { test: function (data) { bar = data; } };
                });

                WORKAREA.analytics.fireCallback('test', 'data');

                expect(foo).to.equal('data');
                expect(bar).to.equal('data');
            });
        });

        describe('setupFormSubmissions', function () {
            it('adds the quantity to the payload', function () {
                this.fixtures = fixture.load(
                    'analytics_add_to_cart_form.html', false
                );

                var result = null;

                WORKAREA.analytics.registerAdapter('gdfg', function () {
                    return {
                        addToCart: function (payload) { result = payload; }
                    };
                });

                WORKAREA.analytics.init($(this.fixtures));

                $('input[name="quantity"]', this.fixtures).val('2');

                $('.product-details__add-to-cart-form', this.fixtures)
                .on('submit', function(e) { e.preventDefault(); })
                .submit();

                expect(result.foo).to.equal('baz');
                expect(result.quantity).to.equal('2');
            });
        });

        describe('init', function () {
            it('sets up product clicks with list and position', function () {
                this.fixtures = fixture.load('analytics_product_click.html', false);

                var result = null;

                WORKAREA.analytics.registerAdapter('test', function () {
                    return {
                        productClick: function (payload) { result = payload; }
                    };
                });

                WORKAREA.analytics.init($(this.fixtures));

                $('#product-list p:eq(1)', this.fixtures).click();

                expect(result.foo).to.equal('bar');
                expect(result.list).to.equal('Foo List');
                expect(result.position).to.equal(4);
            });
        });
    });
}());
