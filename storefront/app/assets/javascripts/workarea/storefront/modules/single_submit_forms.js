// TODO: v4 deprecate in favor of jQuery UJS
/**
 * @namespace WORKAREA.singleSubmitForms
 */
WORKAREA.registerModule('singleSubmitForms', (function () {
    'use strict';

    var preventSubmission = function (event) {
            event.preventDefault();
        },

        preventFurtherSubmissionsIfValid = function (event) {
            var $form = $(event.currentTarget);

            if ($form.valid()) {
                $form
                .off('submit.singleSubmitForms')
                .on('submit', preventSubmission);
            }
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.singleSubmitForms
         */
        init = function ($scope) {
            $('[data-single-submit-form]', $scope)
            .on('submit.singleSubmitForms', preventFurtherSubmissionsIfValid);
        };

    return {
        init: init
    };
}()));
