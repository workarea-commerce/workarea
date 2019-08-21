/**
 * @namespace WORKAREA.optionButtons
 */
WORKAREA.registerModule('optionButtons', (function () {
    'use strict';

    var replaceProductDetails = function (event) {
            var $link = $(event.delegateTarget),
                newUrl = $link.attr('href');

            event.preventDefault();

            $.get(newUrl, function (html) {
                var $newDetails = $(html)
                                    .find('.product-details')
                                        .addBack('.product-details');

                $link.closest('.product-details').replaceWith($newDetails);

                if (_.isEmpty($newDetails.closest('.ui-dialog'))) {
                    window.history.replaceState(null, null, newUrl);
                }

                WORKAREA.initModules($newDetails);
            });
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.optionButtons
         */
        init = function ($scope) {
            $('[data-option-button]', $scope).on('click', replaceProductDetails);
        };

    return {
        init: init
    };
}()));
