/**
 * @namespace WORKAREA.taxonSelect
 */
WORKAREA.registerModule('taxonSelect', (function () {
    'use strict';

    var updatePreview = function (container) {
            var $selectedTaxon = $('[data-taxon-selected]', container),
                $taxonIdField = $('input[type=hidden]:first', container),
                selectedTaxonId = $selectedTaxon.data('taxonSelected');

            $taxonIdField.val(selectedTaxonId).trigger('change');
        },

        replaceTaxonomy = function (container, response) {
            $('[data-taxon-selected]', container).replaceWith(response);
            return container;
        },

        updateTaxonomy = _.flow(replaceTaxonomy, updatePreview),

        fetchTaxonomy = function (event) {
            event.preventDefault();

            $.get(event.currentTarget.href)
            .done(_.partial(updateTaxonomy, event.delegateTarget));
        },

        reset = function (event) {
            event.preventDefault();

            $.get(WORKAREA.routes.admin.selectNavigationTaxonsPath())
            .done(_.partial(updateTaxonomy, event.delegateTarget));
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.taxonSelect
         */
        init = function ($scope) {
            $('[data-taxon-select]', $scope)
            .on('click', 'a', fetchTaxonomy)
            .on('click', 'button[value=reset]', reset);
        };

    return {
        init: init
    };
}()));
