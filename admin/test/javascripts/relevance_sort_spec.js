(function () {
    'use strict';

    describe('WORKAREA.relevanceSort', function () {
        describe('init', function () {
            it('autoselects relevance on keyup', function () {
                this.fixtures = fixture.load('sort_form.html', true);

                var $input = $('input[name=q]', this.fixtures),
                    $select = $('select[name=sort]', this.fixtures);

                WORKAREA.relevanceSort.init($(this.fixtures));
                expect($select.val()).to.equal('name');

                $input.trigger('keyup');
                expect($select.val()).to.equal('name');

                $input.val('foo').trigger('keyup');
                expect($select.val()).to.equal('relevance');
            });
        });
    });
}());
