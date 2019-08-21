/**
 * @namespace WORKAREA.dialogCloseButtons
 */
WORKAREA.registerModule('dialogCloseButtons', (function () {
    'use strict';

    var closeDialog = function (event) {
            var $closestDialog = WORKAREA.dialog.closest(event.currentTarget);

            if (_.isEmpty($closestDialog)) { return; }

            event.preventDefault();

            $closestDialog.dialog('close');
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.dialogCloseButtons
         */
        init = function ($scope) {
            $('[data-dialog-close-button]', $scope).on('click', closeDialog);
        };

    return {
        init: init
    };
}()));
