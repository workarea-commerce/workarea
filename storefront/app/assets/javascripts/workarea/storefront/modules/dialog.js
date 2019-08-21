/**
 * @namespace WORKAREA.dialog
 */
WORKAREA.registerModule('dialog', (function () {
    'use strict';

    var

        /**
         * Private
         */

        close = function ($dialogs) {
            if (_.isEmpty($dialogs)) { return; }

            $dialogs.dialog('close');
        },

        destroy = function (event) {
            $(event.target).dialog('destroy');
        },

        adjustWidth = function ($dialog) {
            var buffer = WORKAREA.config.dialog.viewportBuffer * 2,
                maxWidth = $(window).width() - buffer;

            if ($dialog.outerWidth() > maxWidth) {
                $dialog.dialog('option', 'width', maxWidth);
            }
        },

        getZIndex = function (index, element) {
            return _.parseInt($(element).dialog('widget').css('z-index'));
        },

        matchesZIndex = function (index, element, zIndex) {
            return getZIndex(index, element) === zIndex;
        },


        /**
         * Public Utility Methods
         */

        /**
         * @method
         * @name all
         * @memberof WORKAREA.dialog
         */
        all = function () {
            return $('.ui-dialog-content');
        },

        /**
         * @method
         * @name closest
         * @memberof WORKAREA.dialog
         */
        closest = function (element) {
            return $(element).closest('.ui-dialog-content');
        },

        /**
         * @method
         * @name top
         * @memberof WORKAREA.dialog
         */
        top = function () {
            var $allDialogs = all(),
                zIndexes = _.toArray($allDialogs.map(getZIndex)),
                maxZIndex = Math.max.apply(null, zIndexes);

            return $allDialogs.filter(_.partialRight(matchesZIndex, maxZIndex));
        },

        /**
         * @method
         * @name current
         * @memberof WORKAREA.dialog
         */
        current = function (element) {
            var $closest = closest(element);

            if (!_.isEmpty($closest)) { return $closest; }

            return top();
        },

        /**
         * @method
         * @name closeAll
         * @memberof WORKAREA.dialog
         */
        closeAll = _.flowRight(close, all),

        /**
         * @method
         * @name closeClosest
         * @memberof WORKAREA.dialog
         */
        closeClosest = _.flowRight(close, closest),

        /**
         * @method
         * @name closeTop
         * @memberof WORKAREA.dialog
         */
        closeTop = _.flowRight(close, top),

        /**
         * @method
         * @name closeCurrent
         * @memberof WORKAREA.dialog
         */
        closeCurrent = _.flowRight(close, current),

        /**
         * @method
         * @name withinDialog
         * @memberof WORKAREA.dialog
         */
        withinDialog = function ($collection) {
            return !_.isEmpty($collection.closest('.ui-dialog-content'));
        },


        /**
         * Public Create Methods
         */

        /**
         * @method
         * @name create
         * @memberof WORKAREA.dialog
         */
        create = function (html, options) {
            var $dialog = $(html).wrap('<div>').parent(),
                $current,
                currentOrigElement;

            options = _.merge({}, WORKAREA.config.dialog.options, options);

            if (options.closeAll) { closeAll(); }

            if (options.replace) {
                $current = current(options.originatingElement);
                currentOrigElement = $current.data('dialog').originatingElement;
                options.originatingElement = currentOrigElement;
                $current.dialog('close');
            }

            $dialog
            .dialog(options.uiDialogOptions)
            .attr('role', 'complementary')
            .on('dialogclose', destroy)
            .data('dialog', { originatingElement: options.originatingElement })
                .dialog('widget').focus();

            adjustWidth($dialog);

            if (options.initModules) { WORKAREA.initModules($dialog); }

            return $dialog;
        },

        /**
         * @method
         * @name createFromTemplate
         * @memberof WORKAREA.dialog
         */
        createFromTemplate = function (template, options) {
            var html = JST[template.path](template.data);

            create(html, options);
        },

        /**
         * @method
         * @name createFromFragmentId
         * @memberof WORKAREA.dialog
         */
        createFromFragmentId = function (fragmentId, options) {
            var promise = $.ajax({
                    url: WORKAREA.url.current(),
                    xhr: WORKAREA.jQuery.createXhrWithoutXhrHeader
                });

            WORKAREA.loading.createLoadingDialog(promise);

            promise
            .done(function (html) {
                var $html = $('#' + fragmentId, html);
                $html.removeClass('hidden-if-js-enabled');
                $html = $html.uniqueClone(true, true, '-dialog-clone');
                create($html, options);
            })
            .fail(_.partial(
                createFromTemplate,
                WORKAREA.config.dialog.errorTemplate
            ));
        },

        /**
         * @method
         * @name createFromPromise
         * @memberof WORKAREA.dialog
         */
        createFromPromise = function (promise, options) {
            WORKAREA.loading.createLoadingDialog(promise);

            promise
            .done(function (html) {
                create(html, options);
            })
            .fail(_.partial(
                createFromTemplate,
                WORKAREA.config.dialog.errorTemplate
            ));
        },

        /**
         * @method
         * @name createFromSrc
         * @memberof WORKAREA.dialog
         */
        createFromSrc = function (src, options) {
            var imageDialogOptions = {
                    uiDialogOptions: { dialogClass: 'ui-dialog-image' }
                },
                promise = WORKAREA.image.get(src);

            options = _.merge({}, imageDialogOptions, options);

            createFromPromise(promise, options);
        },

        /**
         * @method
         * @name createFromUrl
         * @memberof WORKAREA.dialog
         */
        createFromUrl = function (url, options) {
            var promise = $.get(url);

            createFromPromise(promise, options);
        },

        /**
         * @method
         * @name createFromForm
         * @memberof WORKAREA.dialog
         */
        createFromForm = function ($form, options) {
            var promise = $.ajax({
                url: $form.attr('action'),
                method: $form.attr('method'),
                data: $form.serialize()
            });

            createFromPromise(promise, options);
        };

    return {
        all: all,
        closest: closest,
        top: top,
        current: current,

        closeAll: closeAll,
        closeClosest: closeClosest,
        closeTop: closeTop,
        closeCurrent: closeCurrent,

        withinDialog: withinDialog,

        create: create,
        createFromTemplate: createFromTemplate,
        createFromFragmentId: createFromFragmentId,
        createFromPromise: createFromPromise,
        createFromSrc: createFromSrc,
        createFromUrl: createFromUrl,
        createFromForm: createFromForm
    };
}()));
