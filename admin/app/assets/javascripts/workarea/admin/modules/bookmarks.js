/**
 * @namespace WORKAREA.bookmarks
 */
WORKAREA.registerModule('bookmarks', (function () {
    'use strict';

    var findBookmarkName = function () {
            return $('head title').text();
        },

        findBookmarkPath = function () {
            return window.location.pathname + window.location.search;
        },

        createBookmark = function (event) {
            var form = JST['workarea/admin/templates/bookmark_form']({
                url: WORKAREA.routes.admin.bookmarksPath(),
                csrfParam: $('meta[name=csrf-param]').attr('content'),
                csrfToken: $('meta[name=csrf-token]').attr('content'),
                name: findBookmarkName(),
                path: findBookmarkPath()
            });

            event.preventDefault();
            $(form).hide().appendTo('body').submit();
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.bookmarks
         */
        init = function ($scope) {
            $('[data-bookmark]', $scope).on('click', createBookmark);
        };

    return {
        init: init
    };
}()));
