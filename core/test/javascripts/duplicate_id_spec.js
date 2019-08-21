//= require workarea/core/modules/environment
//= require workarea/core/modules/duplicate_id

(function () {
    'use strict';

    describe('WORKAREA.duplicateId', function () {
        describe('init', function () {
            it('throws error on duplicate ids', function () {
                this.fixtures = fixture.load('duplicate_id.html');
                expect(WORKAREA.duplicateId.init).to.throw(Error, /foo|bar/);
            });
        });
    });
}());
