/**
 * @namespace WORKAREA.adminToolbar
 */
WORKAREA.registerModule('adminToolbar', (function () {
    'use strict';

    var focusSearch = function ($toolbar) {
            var $scope = $toolbar.contents();

            $('#primary_nav_admin_search', $scope).trigger('focus');
        },

        collapse = function ($toolbar) {
            var $header = $('.header', $toolbar.contents());

            $toolbar.removeClass('admin-toolbar--expanded');
            $header.removeClass('header--takeover');
        },

        expand = function ($toolbar) {
            var $header = $('.header', $toolbar.contents());

            $toolbar.addClass('admin-toolbar--expanded');
            $header.addClass('header--takeover');
        },

        bindEscapeKey = function ($toolbar) {
            var toolbarWindow = $toolbar[0].contentWindow;

            $(toolbarWindow).on('keyup.adminToolbar', function (event) {
                if (event.keyCode !== 27) { return; } // only care about escape
                collapse($toolbar);
            });
        },

        bindTakeoverToggle = function ($toolbar) {
            var $scope = $toolbar.contents(),
                triggerSelectors = [
                    '.header__search-form',
                    '.header__menu-button'
                ].join(',');

            $(triggerSelectors, $scope).on('click', function (event) {
                event.preventDefault();

                if ($(event.currentTarget).is('.header__menu-button--close')) {
                    collapse($toolbar);
                } else {
                    expand($toolbar);
                    focusSearch($toolbar);
                }
            });

            return $toolbar;
        },

        notify = function ($toolbar) {
            $(window).trigger('adminToolbar:loaded');
            return $toolbar;
        },

        url = function () {
            var globalId = $('meta[property="global-id"]').attr('content'),
                params = {};

            params.return_to = window.location.href;
            if (globalId) { params.id = globalId; }

            return '/admin/toolbar?' + $.param(params);
        },

        shouldDisplay = function (user) {
            var disable = WORKAREA.url.parse(window.location).queryKey.disable_admin_toolbar;

            return user.impersonating
                || user.browsing_as_guest
                || (user.admin && user.logged_in && disable !== 'true');
        },

        create = function (user) {
            if ( ! shouldDisplay(user)) { return; }

            $('<iframe />').attr({
                src: url(),
                scrolling: 'no', // technically unsupported, but required
                class: 'admin-toolbar',
                id: 'admin-toolbar',
                role: 'document',
                title: 'Admin Toolbar'
            })
            .prependTo('body')
            .on('load', function (event) {
                var $toolbar = $(event.currentTarget);
                _.flow(notify, bindTakeoverToggle, bindEscapeKey)($toolbar);
            });
        },

        init = _.once(function () {
            if ( ! _.isEmpty($('[data-disable-admin-toolbar]'))) { return; }
            if (WORKAREA.breakPoints.currentlyLessThan('medium')) { return; }
            WORKAREA.currentUser.gettingUserData.done(create);
        });

    return {
        init: init
    };
}()));
