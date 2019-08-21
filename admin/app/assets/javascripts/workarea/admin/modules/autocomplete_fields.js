/**
 * @namespace WORKAREA.autocompleteFields
 */
WORKAREA.registerModule('autocompleteFields', (function () {
    'use strict';

    var addPlaceholder = function ($field) {
            var placeholder = $field.prop('placeholder') ||
                I18n.t('workarea.admin.js.autocomplete_fields.placeholder');

            $field.prop('placeholder', placeholder);
        },

        getSource = function (url) {
            return function (request, response) {
                $.getJSON(url, { q: request.term }, function (data) {
                    response(data.results);
                });
            };
        },

        initAutocomplete = function ($field) {
            var url = $field.data('autocompleteField');

            return $field.autocomplete({
                minLength: 2,
                source: getSource(url),
                position: {
                    my: 'center top',
                    at: 'center bottom',
                    collision: 'none'
                }
            });
        },

        defineInjectionPoint = function (index, field) {
            $(field).parent().addClass('ui-front');
            return $(field);
        },

        setup = _.flow(defineInjectionPoint, initAutocomplete, addPlaceholder),

        /**
         * @method
         * @name init
         * @memberof WORKAREA.autocompleteFields
         */
        init = function ($scope) {
            $('[data-autocomplete-field]', $scope).each(setup);
        };

    return {
        init: init
    };
}()));
