/**
 * Manages the Sticky presentation of the content editor.
 *
 * @namespace WORKAREA.contentEditor
 */
WORKAREA.registerModule('contentEditor', (function () {
    'use strict';

    var calculateOffset = function (editor) {
            var editorTopOffset = $(editor).offset().top,
                headerHeight = $('#header').height(),
                pageContentPadding = window.parseInt(
                    $(editor).closest('.page-content').css('paddingTop')
                ) + window.parseInt(
                    $(editor).closest('.page-content__main').css('paddingTop')
                );

            return (headerHeight + pageContentPadding - editorTopOffset);
        },

        makeSticky = function (index, editor) {
            if ($(editor).data('contentEditorSticky')) { return; }

            $(editor).data('contentEditorSticky', new Waypoint.Sticky({
                element: editor,
                stuckClass: 'content-editor--stuck',
                wrapper: false,
                offset: calculateOffset(editor)
            }));
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.contentEditor
         */
        init = function ($scope) {
            $('.content-editor', $scope).each(makeSticky);
        };

    return {
        init: init
    };
}()));
