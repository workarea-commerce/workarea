/**
 * @namespace WORKAREA.recommendationsPlaceholders
 */
WORKAREA.registerModule('recommendationsPlaceholders', (function () {
    'use strict';

    var replacePlaceholder = function (placeholder, content) {
            var $content = $(content);

            $(placeholder).replaceWith($content);

            WORKAREA.initModules($content);
        },

        getContent = function (index, placeholder) {
            var url = $(placeholder).data('recommendationsPlaceholder');

            $.get(url).done(_.partial(replacePlaceholder, placeholder));
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.recommendationsPlaceholders
         */
        init = function ($scope) {
            $('[data-recommendations-placeholder]', $scope).each(getContent);
        };

    return {
        init: init
    };
}()));
