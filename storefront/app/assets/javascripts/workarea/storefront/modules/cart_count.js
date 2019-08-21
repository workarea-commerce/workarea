/**
 * @namespace WORKAREA.cartCount
 */
WORKAREA.registerModule('cartCount', (function () {
    'use strict';

    var cartCountTemplate = JST['workarea/storefront/templates/page_header_cart_count'],

        update = function ($cartCount, quantity) {
            $cartCount.replaceWith(cartCountTemplate({
                quantity: quantity
            }));
        },

        show = function (quantity) {
            var $cartCount = $('#cart_link .page-header__cart-count');

            if (_.isEmpty($cartCount)) {
                create(quantity);
            } else {
                update($cartCount, quantity);
            }
        },

        create = function (quantity) {
            $('#cart_link').append(cartCountTemplate({
                quantity: quantity
            }));
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.cartCount
         */
        init = function ($scope) {
            var quantity = $('[data-cart-count]', $scope).data('cartCount');

            if (_.isUndefined(quantity)) { return; }

            show(quantity);
        };

    WORKAREA.currentUser.gettingUserData.done(function (user) {
        create(user.cart_quantity);
    });

    return {
        init: init
    };
}()));
