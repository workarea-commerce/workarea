(function () {
    'use strict';

    describe('WORKAREA.menuEditorMenuListSortables', function () {
        describe('addToParent', function () {
            /*jshint multistr: true */
            it('returns a boolean based on given elements', function () {

                this.fixtures = fixture.load(
                    'menu_editor_menu_list_sortable.html', false
                );

                expect(WORKAREA.menuEditorMenuListSortables.addToParent(
                    $('.menu-editor__list-item--placeholder'),
                    $()
                )).to.equal(true);

                expect(WORKAREA.menuEditorMenuListSortables.addToParent(
                    $(),
                    $('.menu-editor__list-item--placeholder')
                )).to.equal(true);

                expect(WORKAREA.menuEditorMenuListSortables.addToParent(
                    $('.menu-editor__list-item--placeholder'),
                    $('.menu-editor__list-item')
                )).to.equal(false);

                expect(WORKAREA.menuEditorMenuListSortables.addToParent(
                    $('.menu-editor__list-item'),
                    $('.menu-editor__list-item--placeholder')
                )).to.equal(false);

                expect(WORKAREA.menuEditorMenuListSortables.addToParent(
                    $('.menu-editor__list-item'),
                    $('.menu-editor__list-item')
                )).to.equal(false);
            });
        });
    });
}());
