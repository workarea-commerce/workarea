(function () {
    'use strict';

    describe('WORKAREA.contentEditorForms', function () {
        describe('buildParams', function () {
            it('merges an array with an object', function () {
                var result = WORKAREA.contentEditorForms.buildParams(
                    [ { name: 'foo', value: 'bar' },
                      { name: '_method', value: 'PATCH' } ],
                    { baz: 'qux' }
                );

                expect(result.length).to.equal(2);
                expect(result).to.contain({ name: 'foo', value: 'bar' });
                expect(result).to.contain({ name: 'baz', value: 'qux' });
                expect(result).to.not.contain({ name: '_method', value: 'PATCH' });
            });
        });
    });
}());
