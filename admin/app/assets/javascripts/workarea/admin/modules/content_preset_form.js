/**
 * Hook onto the content preset tooltip form so that it dismisses when
 * form is submitted asynchronously.
 *
 * @namespace WORKAREA.contentPresetForm
 */
WORKAREA.registerModule('contentPresetForm', (function () {
    'use strict';

    var dismissTooltip = function($button) {
            $button.tooltipster('close');
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.contentPresetForm
         */
        init = function($scope) {
            var $form = $('[data-content-preset-form]', $scope),
                $button = $('[data-content-preset-button]');

            $form.on('ajax:success', _.partial(dismissTooltip, $button));
        };

    return {
        init: init
    };
}()));
