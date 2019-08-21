(function () {
    'use strict';

    describe('WORKAREA.directUploads', function () {
        var mockFile = function (filename) {
                var file = new window.Blob();

                file.lastModifiedDate = new Date();
                file.name = filename;
                file.$element = $(JST['workarea/admin/templates/direct_upload_table_row'](
                    { fileName: filename }
                ));

                return file;
            };

        beforeEach(function () {
            var requests = {
                savingFilePromise: $.Deferred(),
                uploadingFilePromise: $.Deferred(),
                gettingUploadEndpointPromise: $.Deferred()
            };

            this.requests = requests;

            sinon.stub(WORKAREA.directUploads, 'savingFile', function () {
                return requests.savingFilePromise;
            });

            sinon.stub(WORKAREA.directUploads, 'uploadingFile', function () {
                return requests.uploadingFilePromise;
            });

            sinon.stub(WORKAREA.directUploads, 'gettingUploadEndpoint', function () {
                return requests.gettingUploadEndpointPromise;
            });

            sinon.stub(WORKAREA.directUploads, 'prepareFiles', function () {
                return [ mockFile() ];
            });

            this.fixture = fixture.load('direct_upload.html');
            this.$messages = $('.page-messages', this.fixtures);
            this.$ui = $('[data-direct-upload]', this.fixture);
        });

        afterEach(function () {
            WORKAREA.directUploads.savingFile.restore();
            WORKAREA.directUploads.uploadingFile.restore();
            WORKAREA.directUploads.gettingUploadEndpoint.restore();
            WORKAREA.directUploads.prepareFiles.restore();
        });

        describe('init', function () {
            it('activates UI on dragover', function () {
                WORKAREA.directUploads.init($(this.fixture));
                this.$ui.trigger('dragover');
                expect(this.$ui.is('.direct-upload--active')).to.equal(true);
            });

            it('activates UI on dragenter', function () {
                WORKAREA.directUploads.init($(this.fixture));
                this.$ui.trigger('dragenter');
                expect(this.$ui.is('.direct-upload--active')).to.equal(true);
            });

            it('indicates UI is processing on drop', function () {
                var message = I18n.t('workarea.admin.direct_uploads.processing_html', {
                        count: 0,
                        total: 1
                    }),
                    $message = $('<span>').html(message);

                WORKAREA.directUploads.init($(this.fixture));
                this.$ui.trigger('drop');

                expect(this.$ui.is('.direct-upload--processing')).to.be.true;
                expect(this.$ui.text()).to.contain($message.text());
            });

            it('disallows drops while processing', function () {
                var text = I18n.t('workarea.admin.direct_uploads.processing_warning');

                WORKAREA.directUploads.init($(this.fixture));
                this.$ui.trigger('drop');
                this.$ui.trigger('drop');

                expect(this.$messages.text()).to.contain(text);
            });
        });

        describe('processFiles', function () {
            it('errors when endpoint requests fail', function () {
                var status = I18n.t('workarea.admin.direct_uploads.failure_status');

                WORKAREA.directUploads.init($(this.fixture));
                this.$ui.trigger('drop');

                this.requests.gettingUploadEndpointPromise.reject({});

                expect(this.$ui.text()).to.contain(status);
            });

            it('errors when upload requests fail', function () {
                var status = I18n.t('workarea.admin.direct_uploads.failure_status');

                WORKAREA.directUploads.init($(this.fixture));
                this.$ui.trigger('drop');

                this.requests.gettingUploadEndpointPromise.resolve({
                    upload_url: 'http://foo.test'
                });

                this.requests.uploadingFilePromise.reject({});

                expect(this.$ui.text()).to.contain(status);
            });

            it('errors when save requests fail', function () {
                var status = I18n.t('workarea.admin.direct_uploads.failure_status');

                WORKAREA.directUploads.init($(this.fixture));
                this.$ui.trigger('drop');

                this.requests.gettingUploadEndpointPromise.resolve({
                    upload_url: 'http://foo.test'
                });

                this.requests.uploadingFilePromise.resolve({});
                this.requests.savingFilePromise.reject({});

                expect(this.$ui.text()).to.contain(status);
            });

            it('succeeds when all requests succeed', function () {
                var status = I18n.t('workarea.admin.direct_uploads.success_status');

                WORKAREA.directUploads.init($(this.fixture));
                this.$ui.trigger('drop');

                this.requests.gettingUploadEndpointPromise.resolve({
                    upload_url: 'http://foo.test'
                });

                this.requests.uploadingFilePromise.resolve({});
                this.requests.savingFilePromise.resolve({});

                expect(this.$ui.text()).to.contain(status);
            });
        });
    });
}());
