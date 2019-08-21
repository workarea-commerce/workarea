/**
 * Manages the handling of copying text to clipboard
 *
 * @namespace WORKAREA.copyToClipboard
 */
WORKAREA.registerModule('copyToClipboard', (function () {
    'use strict';

    var copyText = function(event) {
            var $button = $(event.target),
                buttonText = $button.text(),
                node = document.querySelector($button.data('copyToClipboard')),
                range = document.createRange();

            range.selectNode(node);
            window.getSelection().addRange(range);

            if (document.execCommand('copy')) {
                $button.text(I18n.t('workarea.messages.copied'));
            } else {
                $button.text(I18n.t('workarea.messages.copy_failed'));
            }

            window.setTimeout(function() { $button.text(buttonText); }, 3000);

            // NOTE: Should use removeRange(range) when it is supported
            window.getSelection().removeAllRanges();
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.copyToClipboard
         */
        init = function ($scope) {
            $('[data-copy-to-clipboard]', $scope).on('click', copyText);
        };

    return {
        init: init
    };
}()));
