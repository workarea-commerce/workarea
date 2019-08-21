/**
 * @namespace WORKAREA.directUploads
 */
WORKAREA.registerModule('directUploads', (function () {
    'use strict';

    var processingTemplate = JST['workarea/admin/templates/direct_upload_processing'],
        tableRowTemplate = JST['workarea/admin/templates/direct_upload_table_row'],

        savingFile = function (type, filename) {
            return $.post({
                url: WORKAREA.routes.admin.directUploadsPath({
                    type: type,
                    filename: filename
                })
            });
        },

        uploadingFile = function (type, file, url) {
            return $.ajax({
                url: url,
                method: 'put',
                data: file,
                contentType: file.type,
                processData: false
            });
        },

        gettingUploadEndpoint = function (type, filename) {
            return $.get({
                url: WORKAREA.routes.admin.newDirectUploadsPath({
                    type: type,
                    filename: filename
                })
            });
        },

        markTableRow = function(status, file, response) {
            var $tableBody = file.$element.closest('tbody');

            file.$element
            .addClass('direct-upload__table-row--' + status)
                .find('[data-direct-upload-file-status]')
                .text(function () {
                    var defaultMessage = I18n.t(
                        'workarea.admin.direct_uploads.' + status + '_status'
                    );

                    if (_.isEmpty((response.responseJSON || {}).error)) {
                        return defaultMessage;
                    } else {
                        return response.responseJSON.error;
                    }
                });

            if (status === 'failure') {
                file.$element.prependTo($tableBody);
            }
        },

        incrementCount = function ($dropzone) {
            var $count = $('[data-direct-upload-count]', $dropzone),
                count = $count.data('directUploadCount') + 1;

            $count.text(count).data('directUploadCount', count);
        },

        stopProcessing = function ($dropzone) {
            $dropzone.removeClass('direct-upload--processing');

            WORKAREA.unsavedChanges.reset();
        },

        scrollToFailures = function ($dropzone) {
            $('html, body').animate({
                scrollTop: $dropzone.offset().top
            }, 1000);
        },

        updateFailUI = function ($dropzone) {
            $dropzone
            .addClass('direct-upload--fail')
                .find('.direct-upload__heading')
                .text(I18n.t('workarea.admin.direct_uploads.something_went_wrong'))
            .end()
                .find('.direct-upload__info')
                .text(I18n.t('workarea.admin.direct_uploads.upload_failed'));
        },

        failUI = function ($dropzone) {
            updateFailUI($dropzone);
            scrollToFailures($dropzone);
        },

        refresh = function ($dropzone) {
            var $takeover = $dropzone.closest('.takeover');

            _.delay(function () {
                if (_.isEmpty($takeover)) {
                    window.location.reload();
                } else {
                    WORKAREA.takeover.reload();
                }
            }, WORKAREA.config.messages.delay);
        },

        updateSuccessUI = function ($dropzone) {
            $dropzone
            .addClass('direct-upload--success')
                .find('.direct-upload__heading')
                .text(I18n.t('workarea.admin.direct_uploads.everything_went_great'))
            .end()
                .find('.direct-upload__info')
                .text(I18n.t('workarea.admin.direct_uploads.upload_succeeded'));
        },

        successUI = function ($dropzone) {
            updateSuccessUI($dropzone);
            refresh($dropzone);
        },

        uploadFile = function (type, $dropzone, file) {
            var endpointRequest = WORKAREA.directUploads.gettingUploadEndpoint(
                    type, file.name
                ),
                uploadPromise = $.Deferred(),
                requests = [];

            requests.push(endpointRequest);

            endpointRequest.done(function (result) {
                var uploadRequest = WORKAREA.directUploads.uploadingFile(
                    type, file, result.upload_url
                );

                requests.push(uploadRequest);

                uploadRequest.done(function () {
                    var saveRequest = WORKAREA.directUploads.savingFile(
                        type, file.name
                    );

                    requests.push(saveRequest);

                    saveRequest.done(function(response) {
                        uploadPromise.resolve.apply(null, requests);
                        markTableRow('success', file, response);
                    }).fail(function (response) {
                        uploadPromise.reject(requests);
                        markTableRow('failure', file, response);
                    });
                }).fail(function (response) {
                    uploadPromise.reject(requests);
                    markTableRow('failure', file, response);
                });
            }).fail(function (response) {
                uploadPromise.reject(requests);
                markTableRow('failure', file, response);
            }).always(_.partial(incrementCount, $dropzone));

            return uploadPromise;
        },


        activateUI = function (event) {
            var $dropzone = $(event.delegateTarget);

            event.preventDefault();
            event.stopPropagation();

            $dropzone.addClass('direct-upload--active');
        },


        prepareFiles = function (event) {
            var data = (event.originalEvent || {}).dataTransfer,
                files;

            if (data.items) {
                files = _.filter(data.items, function (item) {
                    return item.kind === 'file';
                });

                files = _.map(files, function (item) {
                    return item.getAsFile();
                });

                data.items.clear();
            } else {
                files = data.files;

                data.clearData();
            }

            return _.map(files, function (file) {
                return Object.defineProperty(file, '$element', {
                    value: $(tableRowTemplate({ fileName: file.name })),
                    writable: false
                });
            });
        },

        testUnload = function ($dropzone) {
            if ($dropzone.data('directUploadProcessing')) {
                WORKAREA.unsavedChanges.set();
            }
        },

        processFiles = function ($dropzone, files) {
            var type = $dropzone.data('directUpload').type,
                upload = _.partial(uploadFile, type, $dropzone),
                done = _.partial(successUI, $dropzone),
                fail = _.partial(failUI, $dropzone),
                always = _.partial(stopProcessing, $dropzone),
                requests = _.map(files, upload);

            $.when.apply($, requests)
            .done(done)
            .fail(fail)
            .always(always);
        },

        processingUI = function ($dropzone, files) {
            var $tableBody;

            $dropzone
            .addClass('direct-upload--processing')
                .data('directUploadProcessing', true)
                .find('.direct-upload__content')
                .empty()
                .append(processingTemplate({ count: 0, total: files.length }));

            $tableBody = $('[data-direct-upload-table-body]', $dropzone);

            _.forEach(files, function (file) {
                $tableBody.append(file.$element);
            });
        },

        thresholdError = function () {
            WORKAREA.messages.insertMessage(
                I18n.t(
                    'workarea.admin.direct_uploads.threshold_error', {
                        count: WORKAREA.config.directUploads.countThreshold,
                        size: WORKAREA.config.directUploads.sizeThreshold
                    }
                ),
                'error'
            );
        },

        thresholdExceeded = function (files) {
            var safeCount = 500,
                safeSize = 500,
                countThreshold = WORKAREA.config.directUploads.countThreshold,
                sizeThreshold = WORKAREA.config.directUploads.sizeThreshold,
                count = files.length,
                size = _.reduce(files, function (totalMegabytes, file) {
                    return totalMegabytes + file.size / 1000000;
                }, 0);

            if (WORKAREA.environment.isDevelopment
             && ! WORKAREA.config.directUploads.suppressWarning) {
                if (countThreshold > safeCount || sizeThreshold > safeSize) {
                    window.console.warn(
                        'WORKAREA.directUploads.thresholdExceeded: you have ' +
                        'increased either the file or file size threshold in ' +
                        'this module\'s configuration. Testing revealed that ' +
                        'raising this value too far past the default ' +
                        'thresholds causes instability and random failure ' +
                        'during the upload process. PROCEED WITH CAUTION!\n\n' +
                        'To suppress this warning, set the `WORKAREA.config.' +
                        'directUploads.suppressWarning` equal to `true`.'
                    );
                }
            }

            return count > countThreshold || size > sizeThreshold;
        },

        processingWarning = function () {
            WORKAREA.messages.insertMessage(
                I18n.t('workarea.admin.direct_uploads.processing_warning'),
                'warning'
            );
        },

        process = function (event) {
            var $dropzone = $(event.delegateTarget),
                files;

            event.preventDefault();

            if ($dropzone.is('.direct-upload--processing')) {
                processingWarning();
            } else {
                files = WORKAREA.directUploads.prepareFiles(event);

                if (thresholdExceeded(files)) {
                    thresholdError();
                } else {
                    processingUI($dropzone, files);
                    processFiles($dropzone, files);
                    testUnload($dropzone);
                }
            }
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.directUploads
         */
        init = function($scope) {
            $('[data-direct-upload]', $scope)
            .on('drop', process)
            .on('dragover dragenter', activateUI);
        };

    return {
        init: init,
        // for testing
        savingFile: savingFile,
        prepareFiles: prepareFiles,
        processFiles: processFiles,
        uploadingFile: uploadingFile,
        gettingUploadEndpoint: gettingUploadEndpoint
    };
}()));
