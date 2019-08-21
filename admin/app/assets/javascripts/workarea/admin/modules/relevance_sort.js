/**
 * @namespace WORKAREA.relevanceSort
 */
WORKAREA.registerModule('relevanceSort', (function () {
    'use strict';

    var selectRelevance = function () {
            var $search = $(this),
                $form = $search.closest('form'),
                $sort = $form.find('select[name=sort]'),
                $option = $sort.find('option[value="relevance"]');

            if ($search.val() && ! _.isEmpty($option)) {
                $sort.val('relevance');
            }
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.relevanceSort
         */
        init = function ($scope) {
            $('input[name=q]', $scope).on('keyup', selectRelevance);
        };

    return {
        init: init
    };
}()));
