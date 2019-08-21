/**
 * @namespace WORKAREA.loading
 */
WORKAREA.registerModule('loading', (function () {
    'use strict';

    var isPending = function (promise) {
            return promise.state() === 'pending';
        },

        removeLoadingIndicator = function () {
            $('.loading').remove();
        },

        closeLoadingDialog = function () {
            var $loadingDialog = $('.ui-dialog-loading .ui-dialog-content');

            if (_.isEmpty($loadingDialog)) { return; }

            $loadingDialog.dialog('close');
        },

        /**
         * @method
         * @name createLoadingIndicator
         * @memberof WORKAREA.loading
         */
        createLoadingIndicator = function (promise, options) {
            var template = JST[WORKAREA.config.loading.loadingIndicatorTemplate],
                $indicator;

            options = _.assign(
                {},
                WORKAREA.config.loading.loadingIndicatorOptions,
                options
            );

            _.delay(function () {
                if (isPending(promise)) {
                    $indicator = $(template(options));
                    $indicator[options.insertionMethod](options.container);
                }
            }, options.delay);

            promise.always(removeLoadingIndicator);

            return promise;
        },

        /**
         * @method
         * @name createLoadingDialog
         * @memberof WORKAREA.loading
         */
        createLoadingDialog = function (promise, options) {
            options = _.assign(
                {},
                WORKAREA.config.loading.loadingDialogOptions,
                WORKAREA.config.loading.loadingIndicatorOptions,
                options
            );

            _.delay(function () {
                if (isPending(promise)) {
                    WORKAREA.dialog.createFromTemplate(
                        WORKAREA.config.loading.loadingDialogTemplate,
                        options
                    );
                }
            }, options.delay);

            promise.always(closeLoadingDialog);

            return promise;
        };

    return {
        createLoadingIndicator: createLoadingIndicator,
        createLoadingDialog: createLoadingDialog
    };
}()));
