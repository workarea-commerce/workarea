/**
 * @namespace WORKAREA.popupButtons
 */
WORKAREA.registerModule('popupButtons', (function () {
    'use strict';

    var getConfig = function (anchor) {
            return _.assign({}, WORKAREA.config.popupButtons,
                $(anchor).data('popupButton')
            );
        },

        getOptionString = function (anchor) {
            return _.map(getConfig(anchor), function (val, key) {
                return key + '=' + val;
            }).join(',');
        },

        openPopup = function (anchor) {
            window.open(anchor.href, '', getOptionString(anchor));
        },

        handleButtonClick = function (event) {
            event.preventDefault();

            openPopup(event.currentTarget);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.popupButtons
         */
        init = function ($scope) {
            $('[data-popup-button]', $scope).on('click', handleButtonClick);
        };

    return {
        init: init,
        getOptionString: getOptionString
    };
}()));
