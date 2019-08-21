(function () {
    'use strict';

    describe('WORKAREA.datepickerFields', function () {
        beforeEach(function () {
            this.fixtures = fixture.load('datepicker_fields.html', true);
        });

        afterEach(function () {
            $('#ui-datepicker-div').remove();
        });

        describe('init', function () {
            it('renders date picker inline', function () {
                var $scope = $('#inline-datepicker', this.fixtures);

                WORKAREA.datepickerFields.init($scope);

                expect($('.datepicker--inline')).to.exist;
            });

            it('converts iso8601 field value to a formatted date', function () {
                var $scope = $('#valid-date-datepicker', this.fixtures);

                WORKAREA.datepickerFields.init($scope);

                expect(
                    $('[name=valid_date_field]').val()
                ).to.equal(
                    strftime(WORKAREA.config.date.formatDate, new Date('2016-06-02T05:00:00+00:00'))
                );
            });

            it('invalid field values are cleared', function () {
                var $scope = $('#invalid-date-datepicker', this.fixtures);

                WORKAREA.datepickerFields.init($scope);

                expect(
                    $('[name=invalid_date_field]').val()
                ).to.equal('');
            });

            it('properly applies the chosen quick range values', function () {
                var $scope = $('#quick-range-datepicker', this.fixtures);

                WORKAREA.datepickerFields.init($scope);

                $('[name=quick_range]').val(function () {
                    return $('[name=quick_range] option').eq(1).attr('value');
                }).trigger('change');

                expect($('[name=starts_at]').val()).to.equal('1984-07-29');
                expect($('[name=ends_at]').val()).to.equal('1984-07-29');

                $('[name=quick_range]').val(function () {
                    return $('[name=quick_range] option').eq(2).attr('value');
                }).trigger('change');

                expect($('[name=starts_at]').val()).to.equal('1999-01-01');
                expect($('[name=ends_at]').val()).to.equal('2018-02-03');
            });
        });
    });
}());
