/**
 * @namespace WORKAREA.pagination
 */
WORKAREA.registerModule('pagination', (function () {
    'use strict';

    var paginationButton = JST['workarea/storefront/templates/pagination_button'],


        //
        // Utility
        //

        appendChildren = function ($pagination, $newChildren) {
            $('[data-pagination-item]:last', $pagination).after($newChildren);
        },

        findMiddleChild = function ($children) {
            var index = Math.floor($children.length / 2);
            return $children.eq(index);
        },


        //
        // State Management
        //

        setSession = function (state) {
            window.history.replaceState({
                pagination: state
            }, document.title, window.location.href);
        },

        getSession = function () {
            return window.history.state.pagination;
        },

        saveUIStateToSession = function ($pagination) {
            var session;

            if ( ! sessionExists()) { return; }

            session = getSession();

            session.scrollTop = $(window).scrollTop();
            session.height = $pagination.height();

            setSession(session);
        },

        saveUrlToSession = function (nextPageUrl) {
            var session = getSession();

            session.pages.push(nextPageUrl);

            setSession(session);
        },

        initSession = function () {
            window.history.replaceState({
                pagination: {
                    pages: [],
                    scrollTop: 0,
                    height: 'auto'
                }
            }, document.title, window.location.href);
        },

        sessionExists = function () {
            var state = window.history.state;
            return (state && ! _.isEmpty(state.pagination));
        },


        //
        // Button Management
        //

        bindNextPageButtonClick = function ($pagination) {
            $('.pagination__button', $pagination)
            .on('click', _.partial(restartPagination, $pagination));
        },

        showNextPageButton = function ($pagination, url) {
            $('.pagination__button', $pagination).replaceWith(paginationButton({
                loading: false,
                nextPageUrl: url
            }));
        },

        removePaginationButton = function ($pagination) {
            $('.pagination__button', $pagination).remove();
        },

        setupPaginationButton = function ($pagination) {
            $('.pagination__button', $pagination).replaceWith(paginationButton({
                loading: true
            }));
        },


        //
        // Response Handling
        //

        handleResponse = function ($pagination, $trigger, url, response) {
            var $newPagination = $('[data-pagination]', response),
                $newChildren = $('[data-pagination-item]', $newPagination),
                $newTrigger = findMiddleChild($newChildren);

            WORKAREA.initModules($newPagination);

            if ($trigger) { destroyWaypoint($trigger); }

            appendChildren($pagination, $newChildren);
            saveUrlToSession(url);
            saveStateToTrigger($newPagination, $newTrigger);
            initWaypoint($newTrigger);
        },

        requestNextPage = function ($pagination, $trigger, url) {
            $.get(url)
            .done(_.partial(handleResponse, $pagination, $trigger, url))
            .fail(_.partial(showNextPageButton, $pagination, url));
        },


        //
        // Waypoints
        //

        destroyWaypoint = function ($trigger) {
            $trigger.data('paginationWaypoint').destroy();
        },

        handleWaypoint = function (direction) {
            var $trigger = $(this.element),
                $pagination = $trigger.closest('[data-pagination]'),
                state = $trigger.data('paginationState');

            if (direction !== 'down') { return; }

            if ( ! sessionExists()) { initSession(); }

            if (state.lastPage) {
                removePaginationButton($pagination);
            } else if (state.currentPage % state.pagesToLoad === 0) {
                showNextPageButton($pagination, state.nextPageUrl);
                bindNextPageButtonClick($pagination);
            } else {
                requestNextPage($pagination, $trigger, state.nextPageUrl);
            }
        },

        initWaypoint = function ($trigger) {
            $trigger.data('paginationWaypoint', new Waypoint({
                element: $trigger[0],
                handler: handleWaypoint,
                offset: 'bottom-in-view'
            }));
        },

        //
        // Setup
        //

        saveStateToTrigger = function ($pagination, $trigger) {
            var state = $pagination.data('pagination');

            $trigger.data('paginationState', _.merge(
                {}, state, WORKAREA.config.pagination
            ));
        },

        restartPagination = function ($pagination, event) {
            event.preventDefault();

            setupPaginationButton($pagination);

            requestNextPage($pagination, false, event.target.href);
        },

        setup = function ($pagination) {
            var $children = $('[data-pagination-item]', $pagination),
                $trigger = findMiddleChild($children);

            saveStateToTrigger($pagination, $trigger);
            initWaypoint($trigger);
            setupPaginationButton($pagination);
        },


        //
        // State Management
        //

        resetUIState = function ($pagination) {
            $pagination.height('auto');
        },

        injectFetchedPage = function ($pagination, lastPage, response) {
            var $newPagination = $('[data-pagination]', response),
                $newChildren = $('[data-pagination-item]', $newPagination),
                $newTrigger = findMiddleChild($newChildren);

            WORKAREA.initModules($newPagination);

            appendChildren($pagination, $newChildren);

            if (lastPage) {
                saveStateToTrigger($newPagination, $newTrigger);
                initWaypoint($newTrigger);
                resetUIState($pagination);
            }
        },

        handleFetchedPages = function (pages, $pagination) {
            _.forEach(pages, function (page, index) {
                var lastPage = (index + 1 === pages.length);

                // Don't use the promise's .done method because there's no
                // guarantee they will be run in order.
                injectFetchedPage($pagination, lastPage, page.responseText);
            });
        },

        fetchPagesFromSession = function () {
            return _.map(getSession().pages, function (url) {
                return $.get(url);
            });
        },

        awaitPageResquests = function ($pagination) {
            var pages = fetchPagesFromSession();

            $.when
            .apply(null, pages)
            .always(_.partial(handleFetchedPages, pages, $pagination));
        },

        recallUIState = function ($pagination) {
            var session = getSession();

            $pagination.height(session.height);
            $(window).scrollTop(session.scrollTop);
        },

        bindPageUnloadEvent = function ($pagination) {
            $(window).on('unload', _.partial(saveUIStateToSession, $pagination));
        },


        //
        // Session Mediator
        //

        checkSession = function (index, pagination) {
            var $pagination = $(pagination);

            bindPageUnloadEvent($pagination);

            if (sessionExists()) {
                recallUIState($pagination);
                awaitPageResquests($pagination);
                setupPaginationButton($pagination);
            } else {
                setup($pagination);
            }
        },


        /**
         * @method
         * @name init
         * @memberof WORKAREA.pagination
         */
        init = function ($scope) {
            $('[data-pagination]', $scope).each(checkSession);
        };

    return {
        init: init
    };
}()));
