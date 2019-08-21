/**
 * @namespace WORKAREA.bulkActionDeletion
 */
WORKAREA.registerModule('bulkActionDeletion', (function () {
    'use strict';

    var generateMessage = function(count) {
            return I18n.t('workarea.admin.bulk_action_deletions.confirmation', { count: count });
        },

        getSessionCount = function($scope) {
            var session = WORKAREA.bulkActionItems.getSession(),
                $countUI = $('[data-bulk-action-item-count]', $scope);

            if (_.isNull(session)) { return $countUI.data('bulkActionItemCount'); }
            return session.count === 0 ? session.initialCount : session.count;
        },

        confirmBulkDelete = function($scope, event) {
            var count = getSessionCount($scope),
                threshold = WORKAREA.config.bulkActionDeletion.threshold,
                message = generateMessage(count);

            if (count < threshold && ! window.confirm(message)) {
                event.preventDefault();
                event.stopImmediatePropagation();
            }
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.bulkActionDeletion
         */
        init = function ($scope) {
            $('[data-bulk-action-deletion]', $scope)
            .on('submit', _.partial(confirmBulkDelete, $scope));
        };

    return {
        init: init
    };
}()));
