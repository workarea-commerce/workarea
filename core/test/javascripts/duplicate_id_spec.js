//= require workarea/core/modules/environment
//= require workarea/core/modules/string
//= require workarea/core/modules/duplicate_id

(function () {
    'use strict';

    describe('WORKAREA.duplicateId', function () {
        describe('init', function () {
            it('throws error on duplicate ids', function () {
                this.fixtures = fixture.load('duplicate_id_fail.html');
                expect(WORKAREA.duplicateId.init).to.throw(Error, /foo|bar/);
            });

            it('should allow for empty ID values', function () {
                this.fixtures = fixture.load('duplicate_id_pass.html');
                expect(WORKAREA.duplicateId.init).to.not.throw(Error);
            });
        });
    });
}());
