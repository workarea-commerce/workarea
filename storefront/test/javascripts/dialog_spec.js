(function () {
    'use strict';

    describe('WORKAREA.dialog', function () {
        var resetDialogZIndexes = function () {
                $('.ui-dialog', document).each(function (index, dialog) {
                    $(dialog).css({ zIndex: 40 + index });
                });
            },

            hasContent = function ($collection, selector) {
                var $result =  $collection.filter(function (index, element) {
                        return $.contains(element, selector);
                    });

                return _.isEmpty($result);
            },

            openDialogCount = function () {
                return WORKAREA.dialog.all().filter(function (index, dialog) {
                    return $(dialog).dialog('isOpen');
                }).length;
            },

            $fixture,
            server;

        beforeEach(function () {
            // load dialog fixture
            $fixture = $(fixture.load('dialog.html', true));

            // autocreate first three dialogs
            $('.auto-dialog', $fixture).each(function (index, content) {
                WORKAREA.dialog.create(content);
            });

            // adjust the dialogs z-indexes
            resetDialogZIndexes();

            // start up the server
            server = sinon.fakeServer.create();
        });

        afterEach(function () {
            // destroy all open dialogs
            _.forEach(WORKAREA.dialog.all(), function (dialog) {
                $(dialog).dialog('destroy');
            });

            // teardown the server
            server.restore();
        });


        describe('all', function () {
            it('returns all dialogs', function () {
                expect(WORKAREA.dialog.all().length).to.equal(3);
            });
        });

        describe('closest', function () {
            it('returns the dialog closest to the given element', function () {
                var secondContent = $('#content-2')[0],
                    $dialog = WORKAREA.dialog.closest(secondContent);

                expect(hasContent($dialog, '#content-2')).to.equal(true);
            });
        });

        describe('top', function () {
            it('returns the dialog in the foreground', function () {
                var $dialog = WORKAREA.dialog.top();

                expect(hasContent($dialog, '#content-3')).to.equal(true);
            });
        });

        describe('current', function () {
            it('returns the closest dialog, if element is found', function () {
                var secondContent = $('#content-2')[0],
                    $dialog = WORKAREA.dialog.current(secondContent);

                expect(hasContent($dialog, '#content-2')).to.equal(true);
            });

            it('returns the top dialog, if element is not found', function () {
                var unknownContent = $('#content-foo')[0],
                    $dialog = WORKAREA.dialog.current(unknownContent);

                expect(hasContent($dialog, '#content-3')).to.equal(true);
            });
        });


        describe('closeAll', function () {
            it('closes all dialogs', function () {
                expect(openDialogCount()).to.equal(3);

                WORKAREA.dialog.closeAll();

                expect(openDialogCount()).to.equal(0);
            });
        });

        describe('closeClosest', function () {
            it('closes the dialog closest to the given element', function () {
                expect(openDialogCount()).to.equal(3);

                WORKAREA.dialog.closeClosest('#content-2');

                expect(openDialogCount()).to.equal(2);

                expect(
                    WORKAREA.dialog.withinDialog($('#content-2'))
                ).to.equal(false);
            });
        });

        describe('closeTop', function () {
            it('closes the dialog in the foreground', function () {
                expect(openDialogCount()).to.equal(3);

                WORKAREA.dialog.closeTop();

                expect(openDialogCount()).to.equal(2);

                expect(
                    WORKAREA.dialog.withinDialog($('#content-3'))
                ).to.equal(false);
            });
        });

        describe('closeCurrent', function () {
            it('closes the closest dialog, if element is found', function () {
                expect(openDialogCount()).to.equal(3);

                WORKAREA.dialog.closeCurrent('#content-2');

                expect(openDialogCount()).to.equal(2);

                expect(
                    WORKAREA.dialog.withinDialog($('#content-2'))
                ).to.equal(false);
            });

            it('closes the top dialog, if element is found', function () {
                expect(openDialogCount()).to.equal(3);

                WORKAREA.dialog.closeCurrent('#foo-bar');

                expect(openDialogCount()).to.equal(2);

                expect(
                    WORKAREA.dialog.withinDialog($('#content-3'))
                ).to.equal(false);
            });
        });


        describe('withinDialog', function () {
            it('determines if a collection is within a dialog', function () {
                expect(
                    WORKAREA.dialog.withinDialog($('#content-1'))
                ).to.equal(true);

                expect(
                    WORKAREA.dialog.withinDialog($('#content-2'))
                ).to.equal(true);

                expect(
                    WORKAREA.dialog.withinDialog($('#content-3'))
                ).to.equal(true);
            });
        });


        describe('create', function () {
            it('creates a dialog', function () {
                var content = $('#manual-dialog')[0];

                WORKAREA.dialog.create(content);

                expect(
                    hasContent(WORKAREA.dialog.all(), '#content-4')
                ).to.equal(true);
            });

            it('creates a dialog, closing all others if told', function () {
                var content = $('#manual-dialog')[0];

                expect(openDialogCount()).to.equal(3);

                WORKAREA.dialog.create(content, {
                    closeAll: true
                });

                expect(openDialogCount()).to.equal(1);

                expect(
                    WORKAREA.dialog.withinDialog($('#content-4'))
                ).to.equal(true);
            });

            it('creates and replaces the current dialog if told', function () {
                var content = $('#manual-dialog')[0];

                expect(
                    hasContent(WORKAREA.dialog.current(), '#content-3')
                ).to.equal(true);

                WORKAREA.dialog.create(content, {
                    replace: true
                });

                expect(
                    hasContent(WORKAREA.dialog.current(), '#content-4')
                ).to.equal(true);
            });

            it('adds appropriate aria role to dialog', function () {
                var $dialog = WORKAREA.dialog.current(),
                    markup = $dialog.prop('outerHTML');

                expect(markup).to.match(/role.+complementary/);
            });
        });

        describe('createFromTemplate', function () {
            it('creates a dialog from a JST template', function () {
                WORKAREA.dialog.createFromTemplate({
                    path: 'workarea/core/templates/lorem_ipsum_view'
                });

                expect($('.ui-dialog-content').text()).to.include('Lorem Ipsum');
            });
        });

        describe('createFromFragmentId', function () {
            it('fetches and clones content from an on-page ID', function () {
                server.respondWith('GET', '/foo/bar',
                    [200, { 'Content-Type': 'text/html; charset=utf-8' },
                    $fixture[0].outerHTML]
                );

                sinon.stub(WORKAREA.url, 'current', function () {
                    return '/foo/bar';
                });

                WORKAREA.dialog.createFromFragmentId('fragment-dialog');

                server.respond();

                expect(
                    WORKAREA.dialog.withinDialog($('#content-5-dialog-clone'))
                ).to.equal(true);

                WORKAREA.url.current.restore();
            });
        });

        describe('createFromPromise', function () {
            it('creates a dialog from a given promise', function () {
                var promise;

                server.respondWith('GET', '/bar/baz',
                    [200, { 'Content-Type': 'text/html; charset=utf-8' },
                    '<div id="promise-content">Dialog Promise Content</div>']
                );

                promise = $.get('/bar/baz');

                server.respond();

                WORKAREA.dialog.createFromPromise(promise);

                expect(
                    WORKAREA.dialog.withinDialog($('#promise-content'))
                ).to.equal(true);
            });
        });

        describe('createFromSrc', function () {
            it('creates an image dialog from a given path', function () {
                sinon.stub(WORKAREA.image, 'get', function () {
                    var $image = $('<img id="image-content" src="">'),
                        deferred = $.Deferred();

                    deferred.resolve.apply(null, [$image]);

                    return deferred.promise();
                });

                WORKAREA.dialog.createFromSrc('/foo.gif');

                resetDialogZIndexes();

                expect(
                    WORKAREA.dialog.withinDialog($('#image-content'))
                ).to.equal(true);

                expect(
                    WORKAREA.dialog.current()
                        .closest('.ui-dialog')
                        .hasClass('ui-dialog-image')
                ).to.equal(true);

                WORKAREA.image.get.restore();
            });
        });

        describe('createFromUrl', function () {
            it('creates a dialog from a given url', function () {
                server.respondWith('GET', '/baz/qux',
                    [200, { 'Content-Type': 'text/html; charset=utf-8' },
                    '<div id="url-content">Dialog URL Content</div>']
                );

                WORKAREA.dialog.createFromUrl('/baz/qux');

                server.respond();

                expect(
                    WORKAREA.dialog.withinDialog($('#url-content'))
                ).to.equal(true);
            });
        });

        describe('createFromForm', function () {
            it('creates a dialog from a given form action', function () {
                var $form = $('#form-dialog');

                server.respondWith('POST', '/qux/quux',
                    [200, { 'Content-Type': 'text/html; charset=utf-8' },
                    '<div id="form-content">Dialog Form Content</div>']
                );

                WORKAREA.dialog.createFromForm($form);

                server.respond();

                expect(
                    WORKAREA.dialog.withinDialog($('#form-content'))
                ).to.equal(true);
            });
        });
    });
}());
