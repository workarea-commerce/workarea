/**
 * @namespace WORKAREA.taxonInsert
 */
WORKAREA.registerModule('taxonInsert', (function () {
    'use strict';

    var setPositionInput = function (event, ui) {
            var $item = $(ui.item);

            $item
                .closest('[data-taxon-selection]')
                    .find('input[name=position]')
                        .val($item.index());
        },

        initPositionDragAndDrop = function (container) {
            $('.menu-editor__menu-list', container)
            .sortable({
                stop: setPositionInput,
                cancel: 'li:not(.handle)'
            });
        },

        replaceTaxonomy = function (container, response) {
            var $newContent = $(response);
            initPositionDragAndDrop($newContent);

            $('[data-taxon-selection]', container).replaceWith($newContent);
            return container;
        },

        fetchTaxonomy = function (taxonId, taxonSelection, container) {
            var url = WORKAREA.routes.admin.insertNavigationTaxonPath({
                    id: taxonId,
                    taxon: taxonSelection,
                    _options: true
                });

            $.get(url).done(_.partial(replaceTaxonomy, container));
        },

        updateSelectMenu = function($select, option) {
            $select.find('option').each(function(index, el) {
                if ($(el).text() === option) {
                    $select[0].selectedIndex = index;
                }
            });
            $select.trigger('change');
        },

        getTaxonSelection = function($el) {
            return $el.closest('[data-taxon-selection]').data('taxonSelection');
        },

        handelTaxonSelectChange = function (event) {
            var taxonId = $(event.target).val(),
                taxonSelection = getTaxonSelection($(event.currentTarget)),
                container = event.delegateTarget;

            fetchTaxonomy(taxonId, taxonSelection, container);
        },

        handleHomeButton = function(event) {
            var taxonId = $(event.currentTarget).data('rootTaxonId'),
                taxonSelection = getTaxonSelection($(event.target)),
                container = event.delegateTarget;

            fetchTaxonomy(taxonId, taxonSelection, container);
        },

        handleTaxonClick = function(event) {
            var $taxon = $(event.currentTarget),
                taxonName = $('.menu-editor__menu-link-text', $taxon).text(),
                $taxonInsert = $taxon.closest('[data-taxon-insert]'),
                $select = $('select', $taxonInsert).last();

            updateSelectMenu($select, taxonName);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.taxonInsert
         */
        init = function ($scope) {
            $('[data-taxon-insert]', $scope)
            .on('change', 'select', handelTaxonSelectChange)
            .on('click', '.menu-editor__list-item', handleTaxonClick)
            .on('click', '.menu-editor__breadcrumbs-home-button', handleHomeButton)
            .each(_.rearg(initPositionDragAndDrop, [1, 0]));
        };

    return {
        init: init
    };
}()));
