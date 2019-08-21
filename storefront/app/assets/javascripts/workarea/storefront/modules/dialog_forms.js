/**
 * @namespace WORKAREA.dialogForms
 */
WORKAREA.registerModule('dialogForms', (function () {
    'use strict';

    var failsJQueryValidation = function ($form) {
            return ('valid' in $form) && (!$form.valid());
        },

        createDialog = function (event, options) {
            var $form = $(event.currentTarget),
                data = $form.data('dialogForm') || {};

            if (failsJQueryValidation($form)) { return; }

            event.preventDefault();

            options = options || data.dialogOptions || {};
            options.originatingElement = $form.get(0);

            WORKAREA.dialog.createFromForm($form, options);
        },

        /**
         * @method
         * @name initDialogForm
         * @memberof WORKAREA.dialogForms
         */
        initDialogForm = function (index, element, options) {
            $(element).on('submit', _.partialRight(createDialog, options));
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.dialogForms
         */
        init = function ($scope) {
            $('[data-dialog-form]', $scope).each(initDialogForm);
        };

    return {
        init: init,
        initDialogForm: initDialogForm
    };
}()));
