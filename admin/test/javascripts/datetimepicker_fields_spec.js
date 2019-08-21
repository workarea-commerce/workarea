(function () {
    'use strict';

    describe('WORKAREA.datetimepickerFields', function () {
        afterEach(function () {
            $('.ui-datepicker').remove();
        });

        describe('init', function () {
            it('renders inputs for date and time', function () {
                var markup = 'datetimepicker_fields.html';

                this.fixtures = fixture.load(markup, true);

                WORKAREA.datetimepickerFields.init($(this.fixtures));

                expect($('#inline_date_field_picker')).to.exist;
                expect($('#inline_date_field_date')).to.exist;
                expect($('#inline_date_field_hours')).to.exist;
                expect($('#inline_date_field_minutes')).to.exist;
                expect($('#inline_date_field_ampm')).to.exist;
            });
        });

        describe('updateDateTimeField', function () {
            it('updates datetime field to new time on form submit', function () {
                var markup = 'datetimepicker_fields.html';

                this.fixtures = fixture.load(markup, true);

                WORKAREA.datetimepickerFields.init($(this.fixtures));

                $('#inline_date_field_date').val('2016-06-02').trigger('change');
                $('#inline_date_field_hours').val('6').trigger('change');
                $('#inline_date_field_minutes').val('30').trigger('change');
                $('#inline_date_field_ampm').val('pm').trigger('change');

                WORKAREA.datetimepickerFields.updateDateTimeField(
                    $('#inline_date_field'),
                    $('.datetimepicker')
                );

                expect(
                    $('#inline_date_field').val()
                ).to.equal(
                    strftime(
                        WORKAREA.config.date.format,
                        new Date(2016, 5, 2, 18, 30)
                    )
                );
            });

            it('Correctly updates 12th hour times to 24h format', function () {
                var markup = 'datetimepicker_fields.html';

                this.fixtures = fixture.load(markup, true);

                WORKAREA.datetimepickerFields.init($(this.fixtures));

                $('#inline_date_field_date').val('2016-06-02').trigger('change');
                $('#inline_date_field_hours').val('12').trigger('change');
                $('#inline_date_field_minutes').val('00').trigger('change');
                $('#inline_date_field_ampm').val('pm').trigger('change');

                WORKAREA.datetimepickerFields.updateDateTimeField(
                    $('#inline_date_field'),
                    $('.datetimepicker')
                );

                expect(
                    $('#inline_date_field').val()
                ).to.equal(
                    strftime(
                        WORKAREA.config.date.format,
                        new Date(2016, 5, 2, 12, 0)
                    )
                );

                $('#inline_date_field_ampm').val('am').trigger('change');

                WORKAREA.datetimepickerFields.updateDateTimeField(
                    $('#inline_date_field'),
                    $('.datetimepicker')
                );

                expect(
                    $('#inline_date_field').val()
                ).to.equal(
                    strftime(
                        WORKAREA.config.date.format,
                        new Date(2016, 5, 2, 0, 0)
                    )
                );
            });
        });
    });
}());
