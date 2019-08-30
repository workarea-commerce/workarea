/**
 * @namespace WORKAREA.styleGuideAutocompleteFields
 */
WORKAREA.registerModule('styleGuideAutocompleteFields', (function () {
    'use strict';

    var AUTOCOMPLETE_DATA = [
            'Small red sweater',
            'Medium red sweater',
            'Large red sweater',
            'Small blue sweater',
            'Medium blue sweater',
            'Large blue sweater',
            'Small green sweater',
            'Medium green sweater',
            'Large green sweater',
            'Small white sweater',
            'Medium white sweater',
            'Large white sweater',
            'Small black sweater',
            'Medium black sweater',
            'Large black sweater',
            'Small yellow sweater',
            'Medium yellow sweater',
            'Large yellow sweater'
        ],

        /**
         * @method
         * @name init
         * @memberof WORKAREA.styleGuideAutocompleteFields
         */
        init = function ($scope) {
            $('[data-style-guide-autocomplete-field]', $scope).autocomplete({
                source: AUTOCOMPLETE_DATA
            });
        };

    return {
        init: init
    };
}()));
