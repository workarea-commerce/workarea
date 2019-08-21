/**
 * @namespace WORKAREA.logOutLinkPlaceholders
 */
WORKAREA.registerModule('logOutLinkPlaceholders', (function () {
    'use strict';

    var logOutLinkTemplate = JST['workarea/storefront/templates/log_out_link'],

        injectLogOutLink = function (index, element) {
            $(element).replaceWith(logOutLinkTemplate());
        },

        testPlaceholders = function ($scope) {
            $('[data-log-out-link-placeholder]', $scope).each(injectLogOutLink);
        },

        testCurrentUser = function ($scope, currentUser) {
            if (!currentUser.logged_in) { return; }

            testPlaceholders($scope);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.logOutLinkPlaceholders
         */
        init = function ($scope) {
            WORKAREA.currentUser.gettingUserData
            .done(_.partial(testCurrentUser, $scope));
        };

    return {
        init: init
    };
}()));
