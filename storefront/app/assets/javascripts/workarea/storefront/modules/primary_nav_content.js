/**
 * @namespace WORKAREA.primaryNavContent
 */
WORKAREA.registerModule('primaryNavContent', (function () {
    'use strict';

    var insertContent = function ($container, content) {
            var $content = $(content);

            WORKAREA.initModules($content);

            $container.append($content);
        },

        clearNavHoverState = function () {
            $('.primary-nav__item--hover').removeClass('primary-nav__item--hover');
        },

        hoverContainer = function ($container) {
            $container.addClass('primary-nav__item--hover');
        },

        containerShouldHover = function ($container) {
            return !$container.hasClass('primary-nav__item--hover');
        },

        fetchContent = function (event) {
            var $container = $(event.delegateTarget),
                url = WORKAREA.routes.storefront.menuPath({
                    id: $container.data('primaryNavContent')
                });

            $.ajax({
                url: url,
                cache: !WORKAREA.currentUser.admin,
                success: _.partial(insertContent, $container)
            });
        },

        handleTouch = function(event) {
            var $container = $(event.delegateTarget);

            if (containerShouldHover($container)) {
                event.preventDefault();
                clearNavHoverState();
                hoverContainer($container);
            }
        },

        testBodyTouch = function (event) {
            var $target = $(event.target),
                $primaryNav = $('#navigation'),
                navHasHoverState = !_.isEmpty($('.primary-nav__item--hover', $primaryNav)),
                clickIsOutsideNav = _.isEmpty($target.closest($primaryNav).addBack($primaryNav));

            if (clickIsOutsideNav && navHasHoverState) {
                clearNavHoverState();
            }
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.primaryNavContent
         */
        init = function ($scope) {
            $('[data-primary-nav-content]', $scope)
            .one('mouseenter touchstart', fetchContent)
            .on('touchstart', handleTouch);
        };

        $('body').on('touchstart.primaryNavContent', testBodyTouch);

    return {
        init: init
    };
}()));
