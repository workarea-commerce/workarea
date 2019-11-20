/**
 * @namespace WORKAREA.impersonationNotification
 */
WORKAREA.registerModule('impersonationNotification', (function () {
    'use strict';

    var pathExcluded = function () {
            var paths = WORKAREA.config.impersonationNotification.excludedPaths;

            return _.reduce(paths, function (result, path) {
                return _.includes(window.location.pathname, path);
            }, false);
        },

        confirm = function ($form) {
            var confirmed = window.confirm(
                $form.data('impersonationNotification')
            );

            if (confirmed) { return; }

            $form.trigger('submit');
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.impersonationNotification
         */
        init = _.once(function ($scope) {
            var $form = $('[data-impersonation-notification]', $scope);

            if (_.isEmpty($form)) { return; }
            if (pathExcluded()) { return; }

            confirm($form);
        });

    return {
        init: init
    };
}()));
