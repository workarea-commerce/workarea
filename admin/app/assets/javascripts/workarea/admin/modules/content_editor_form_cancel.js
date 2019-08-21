/**
 * @namespace WORKAREA.contentEditorFormCancel
 */
WORKAREA.registerModule('contentEditorFormCancel', (function () {
    'use strict';

    var disableEditMode = function(event) {
            var $cancelButton = $(event.currentTarget),
                $editor = $cancelButton.closest('.content-editor'),
                $activeBlock = $('.content-block--active', $editor);

            event.preventDefault();
            WORKAREA.contentBlocks.deactivateBlock($activeBlock);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.contentEditorFormCancel
         */
        init = function ($scope) {
            $('[data-content-editor-form-cancel]', $scope)
            .on('click', disableEditMode);
        };

    return {
        init: init
    };
}()));
