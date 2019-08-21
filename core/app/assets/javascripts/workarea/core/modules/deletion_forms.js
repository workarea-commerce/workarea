/**
 * @namespace WORKAREA.deletionForms
 */
WORKAREA.registerModule('deletionForms', (function () {
    'use strict';

    var getConfig = function ($form) {
            return _.assign({}, WORKAREA.config.deletionForms,
                $form.data('deletionForm')
            );
        },

        promptForConfirmation = function (message) {
            return window.confirm(message);
        },

        handleFormSubmission = function (event) {
            var $form = $(event.target),
                message = getConfig($form).message,
                choice = promptForConfirmation(message);

            if (choice) {
                $form.trigger('deletionForm:confirmed');
            } else {
                $form.trigger('deletionForm:canceled');
            }

            return choice;
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.deletionForms
         */
        init = function ($scope) {
            $('form', $scope).has('input[name="_method"][value="delete"]')
                .not('[data-disable-delete-confirmation]')
                .on('submit', handleFormSubmission);
        };

    return {
        init: init
    };
}()));
