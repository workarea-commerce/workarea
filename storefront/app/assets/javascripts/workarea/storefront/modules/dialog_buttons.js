/**
 * @namespace WORKAREA.dialogButtons
 */
WORKAREA.registerModule('dialogButtons', (function () {
    'use strict';

    var isSrc = function (fileName) {
            var extension = WORKAREA.url.parse(fileName).path.split('.').pop();

            return _.includes(WORKAREA.config.imageFileExtensions, extension);
        },

        createDialog = function (event, options) {
            var element = event.currentTarget,
                url = element.href,
                parsedUrl = WORKAREA.url.parse(url),
                fileName = parsedUrl.file,
                data = $(element).data('dialogButton') || {},
                template = data.template,
                fragmentId = parsedUrl.anchor;

            event.preventDefault();

            options = options || data.dialogOptions || {};
            options.originatingElement = element;

            if (template) {
                WORKAREA.dialog.createFromTemplate(template, options);
                return;
            }

            if (fragmentId) {
                WORKAREA.dialog.createFromFragmentId(fragmentId, options);
                return;
            }

            if (fileName && isSrc(fileName)) {
                WORKAREA.dialog.createFromSrc(url, options);
                return;
            }

            WORKAREA.dialog.createFromUrl(url, options);
        },

        /**
         * @method
         * @name initDialogButton
         * @memberof WORKAREA.dialogButtons
         */
        initDialogButton = function (index, element, options) {
            $(element).on('click', _.partialRight(createDialog, options));
        },

        /**
         * Module behavior can be augmented by supplying a JSON object as the
         * value of `[data-dialog-button]` :
         *
         * {
         * 		dialogOptions: {
         * 			uiDialogOptions: {
         * 				modal: true // example
         * 			}
         * 		}
         * }
         *
         * @method
         * @name init
         * @memberof WORKAREA.dialogButtons
         */
        init = function ($scope) {
            $('[data-dialog-button]', $scope).each(initDialogButton);
        };

    return {
        init: init,
        initDialogButton: initDialogButton
    };
}()));
