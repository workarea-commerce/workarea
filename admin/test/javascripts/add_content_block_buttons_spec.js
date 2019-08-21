(function () {
    'use strict';

    describe('WORKAREA.addContentBlockButtons', function () {
        describe('reorder', function () {
            it('updates the position param for each content block add button', function () {
                this.fixtures = fixture.load('add_content_block_button.html');

                WORKAREA.addContentBlockButtons.reorder();
                var $links = $('#content_editor a');

                expect(_.includes($links[0].href, 'position=2')).to.equal(true);
                expect(_.includes($links[1].href, 'position=3')).to.equal(true);
                expect(_.includes($links[2].href, 'position=1')).to.equal(true);
                expect(_.includes($links[3].href, 'position=2')).to.equal(true);
                expect(_.includes($links[4].href, 'position=0')).to.equal(true);
                expect(_.includes($links[5].href, 'position=1')).to.equal(true);
            });
        });
    });
}());
