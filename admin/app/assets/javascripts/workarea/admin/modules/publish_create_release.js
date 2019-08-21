/**
 * @namespace WORKAREA.publishCreateRelease
 */
WORKAREA.registerModule('publishCreateRelease', (function () {
    'use strict';

    var showReleaseUI = function($context) {
            $('.publish-create-release__fields', $context).removeClass('hidden');
            $('.publish-create-release__fields .text-box', $context).attr('required', 'required');
        },

        hideReleaseUI = function($context) {
            $('.publish-create-release__fields', $context).addClass('hidden');
            $('.publish-create-release__fields .text-box', $context).removeAttr('required');
        },

        handleChangeEvent = function(event) {
            var $input = $(event.currentTarget),
                $context = $input.closest('[data-publish-create-release]');

            if ($input.val() === 'new_release' ) {
                showReleaseUI($context);
            } else {
                hideReleaseUI($context);
            }
        },
        /**
         * @method
         * @name init
         * @memberof WORKAREA.publishCreateRelease
         */
        init = function ($scope) {
            $('[data-publish-create-release]', $scope)
            .on('change', 'input:radio', handleChangeEvent);
        };

    return {
        init: init
    };
}()));
