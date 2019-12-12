/**
 * @namespace WORKAREA.singleSubmitForms
 */
WORKAREA.registerModule('singleSubmitForms', (function () {
    'use strict';

    var disableSubmit = function (event) {
            $(':submit', event.delegateTarget).attr('disabled', true);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.singleSubmitForms
         */
        init = function ($scope) {
            $('form', $scope).on('submit.singleSubmitForms', disableSubmit);
        };

    return {
        init: init
    };
}()));
