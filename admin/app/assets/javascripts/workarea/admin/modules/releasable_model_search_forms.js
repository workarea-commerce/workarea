/**
 * @namespace WORKAREA.releasableModelSearchForms
 */
WORKAREA.registerModule('releasableModelSearchForms', (function () {
    'use strict';

    var getSource = function (form, request, response) {
            var params = { q: request.term, format: 'json' };

            $.getJSON(form.action, params, function (data) {
                response(data.results);
            });
        },

        openSelected = function (event, ui) {
            window.location = ui.item.url;
        },

        initCategorizedAutocomplete = function (index, form) {
            $('.search-form__input', form).categorizedAutocomplete({
                minLength: 2,
                source: _.partial(getSource, form),
                select: openSelected
            });
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.releasableModelSearchForms
         */
        init = function ($scope) {
            $('[data-releasable-model-search-form]', $scope)
            .on('submit', function (event) { event.preventDefault(); })
            .each(initCategorizedAutocomplete);
        };

    return {
        init: init
    };
}()));

