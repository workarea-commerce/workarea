/**
 * @namespace WORKAREA.primaryNav
 */
WORKAREA.registerModule('primaryNav', (function () {
    'use strict';

    var focusSearchForm = function ($takeover) {
            $('.search-form__input', $takeover).trigger('focus');
        },

        getNavContent = function (event) {
            event.preventDefault();
            return $(event.currentTarget.hash).prop('innerHTML');
        },

        open = function(event) {
            var takeover = WORKAREA.takeover.open(
                getNavContent(event),
                { 'takeoverClass': 'takeover--from-top' }
            );

            focusSearchForm(takeover);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.primaryNav
         */
        init = function ($scope) {
            $('[data-primary-nav]', $scope).on('click', open);
        };

    return {
        init: init
    };
}()));
