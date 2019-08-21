(function () {
    'use strict';

    describe('WORKAREA.contentEditorFormCancel', function () {
        describe('init', function () {
            it('closes the edit form when clicked', function () {
                var $fixture = $(fixture.load('content_block_editor_form.html'));

                WORKAREA.contentEditorFormCancel.init($fixture);

                $('.content-block').addClass('content-block--inactive');
                $('[data-content-editor-form-cancel]').trigger('click');

                expect(_.isEmpty($('.content-block--active'))).to.equal(true);
                expect($('.content-editor__aside').css('display')).to.equal('block');
            });
        });
    });
}());
