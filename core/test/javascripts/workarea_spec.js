(function () {
    'use strict';

    describe('WORKAREA', function () {
        afterEach(function () {
            delete window.WORKAREA.foo;
        });

        describe('registerModule', function () {
            it('adds the module to the global WORKAREA object', function () {
                var module = {};
                WORKAREA.registerModule('foo', module);

                expect(WORKAREA).to.have.property('foo');
                expect(WORKAREA.foo).is.an('object');
                expect(WORKAREA.foo).to.eq(module);
            });

            it('throws an error if module is already registered', function () {
                var register = function () {
                    WORKAREA.registerModule('foo', $.noop);
                };

                sinon.spy(WORKAREA, 'registerModule');

                expect(register).to.not.throw(Error);
                expect(register).to.throw(Error, '`foo` already exists');

                WORKAREA.registerModule.restore();
            });
        });

        describe('initModules', function () {
            it('invokes each registered module\'s init method', function () {
                var module = (function () {
                    return { init: sinon.spy() };
                })();

                WORKAREA.registerModule('foo', module);
                WORKAREA.initModules($('<span>'));

                expect(WORKAREA.foo.init.calledOnce).to.be.true;
            });

            it('throws an error if supplied $scope is not a jQuery object', function () {
                var initModules = function () { WORKAREA.initModules('foo'); };
                expect(initModules).to.throw(Error, 'must be a jQuery Object');
            });

            it('throws an error if modules have been reinitialized on the same scope', function () {
                var initModules = function () {
                        WORKAREA.initModules($('.scope-foo'));
                        WORKAREA.initModules($('.scope-bar'));
                    },
                    reinitModules = function () {
                        WORKAREA.initModules($('.scope-foo'));
                    };

                this.fixtures = fixture.load('workarea_scope.html');

                expect(initModules).to.not.throw(Error);
                expect(reinitModules).to.throw(Error, /class.+scope-foo/);
            });
        });
    });
}());
