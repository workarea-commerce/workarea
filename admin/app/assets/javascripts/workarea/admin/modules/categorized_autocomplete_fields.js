/**
 * @namespace WORKAREA.categorizedAutocompleteFields
 */
WORKAREA.registerModule('categorizedAutocompleteFields', (function () {
    'use strict';

    var getSource = function (request, response) {
            $.getJSON(WORKAREA.routes.admin.jumpToPath(), { q: request.term }, function (data) {
                response(data.results);
            });
        },

        openSelected = function (event, ui) {
            var $adminToolbar = $(event.target).closest('.admin-toolbar');

            if (_.isEmpty($adminToolbar)) {
                Turbolinks.visit(ui.item.url);
            } else {
                window.top.location.href = ui.item.url;
            }
        },

        getConfig = function () {
            return _.assign({}, WORKAREA.config.categorizedAutocompleteFields.uiOptions, {
                source: getSource,
                select: openSelected,
                position: {
                    my: 'center top',
                    at: 'center bottom',
                    collision: 'none'
                }
            });
        },

        initAutocomplete = function ($field) {
            $field.categorizedAutocomplete(getConfig());
        },

        defineInjectionPoint = function (index, field) {
            $(field).parent().addClass('ui-front');
            return $(field);
        },

        setup = _.flow(defineInjectionPoint, initAutocomplete),

        /**
         * @method
         * @name init
         * @memberof WORKAREA.categorizedAutocompleteFields
         */
        init = function ($scope) {
            $('[data-categorized-autocomplete-field]', $scope).each(setup);
        };

    return {
        init: init
    };
}()));
