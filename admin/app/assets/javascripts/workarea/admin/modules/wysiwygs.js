/**
 * @namespace WORKAREA.wysiwygs
 */
WORKAREA.registerModule('wysiwygs', (function () {
    'use strict';

    var toolbarTemplate = JST['workarea/admin/templates/wysiwyg_toolbar'],

        getEditorConfig = function (toolbarId) {
            return _.assign({}, WORKAREA.config.wysiwygs.uiOptions, {
                toolbar: toolbarId,
                parserRules: WORKAREA.config.wysiwygs.parserRules
            });
        },

        announceWysiwygInput = function ($wysiwyg) {
            $wysiwyg.trigger('wysiwygs:input');
        },

        setupWysiwygIframe = function ($wysiwyg) {
            var $iframe = $('iframe', $wysiwyg),
                iframeBody = $iframe[0].contentDocument.body,
                announceInput = _.partial(announceWysiwygInput, $wysiwyg);

            $iframe.addClass('wysiwyg__iframe');

            $(iframeBody).on('input', announceInput);

            new window.MutationObserver(function () {
                announceWysiwygInput($wysiwyg);
            }).observe(iframeBody, {
                childList: true,
                subtree: true
            });
        },

        initEditor = function ($wysiwyg, textarea, toolbarId) {
            var config = getEditorConfig(toolbarId),
                editor = new wysihtml.Editor(textarea, config);

            editor.on('load', _.partial(setupWysiwygIframe, $wysiwyg));

            $wysiwyg.data('wysiwygEditor', editor);
        },

        setupWysiwygToolbar = function ($wysiwyg, textarea, toolbarId) {
            var $toolbar = $(toolbarTemplate({ id: toolbarId }));

            $toolbar.prependTo($wysiwyg);
        },

        setupWysiwygEditor = function (index, wysiwyg) {
            var $wysiwyg = $(wysiwyg),
                textarea = $wysiwyg.find('textarea')[0],
                toolbarId = textarea.id + '_toolbar_' + index;

            setupWysiwygToolbar($wysiwyg, textarea, toolbarId);
            initEditor($wysiwyg, textarea, toolbarId);
        },

        /**
         * Pseudo Destroy method - prevents turbolinks error
         * wysihtml does not provide a destroy method in v0.6
         */
        destroy = function(index, wysiwyg) {
            $('iframe', wysiwyg).remove();
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.wysiwygs
         */
        init = function ($scope) {
            $('[data-wysiwyg]', $scope)
                .addBack('.wysiwyg')
                .each(setupWysiwygEditor);
        };

    $(window).on('turbolinks:before-visit', function () {
        $('[data-wysiwyg]').each(destroy);
    });

    return {
        init: init
    };
}()));
