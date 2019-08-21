require 'test_helper'

module Workarea
  module Admin
    class ReleasesHelperTest < ViewTest
      def test_release_options
        release = create_release
        published_release = create_release(published_at: 3.weeks.ago)

        self.expects(:current_release).returns(published_release).at_least_once
        Release.expects(:upcoming).returns([published_release, release])

        assert_equal(2, release_options.size)
        assert_equal([published_release.id, release.id], release_options.map(&:id))
        assert(release_options.all? { |ro| ro.is_a?(ReleaseViewModel) })
      end

      def test_change_display_value
        assert_equal('Yes', change_display_value(true))
        assert_equal('No', change_display_value(false))

        assert_equal('string', change_display_value('string'))

        assert(change_display_value(Time.current).is_a?(String))
        assert(change_display_value(DateTime.current).is_a?(String))

        assert_equal('Yes, No', change_display_value([true, false]))

        assert_equal(
          "#{Money.default_currency.symbol}5.00",
          change_display_value(5.to_m)
        )

        assert_match(/<a.*<\/a>/, change_display_value('http://example.com'))
      end

      def test_for_each_content_block_from_changeset
        content = create_content(blocks: [{ area: 'foo', type: 'html' }])

        changes = {
          content.blocks.first.id => {
            'data' => { 'en' => { 'html' => 'changes' } }
          },
          'missing_block_id' => {
            'data' => { 'en' => { 'html' => 'changes' } }
          }
        }

        count = 0

        for_each_content_block_from_changeset(content, changes) do |*|
          count += 1
        end

        assert_equal(1, count)

        for_each_content_block_from_changeset(content, changes) do |tmp_block, tmp_changes|
          assert_equal(content.blocks.first, tmp_block)
          assert_equal(
            { 'data' => { 'en' => { 'html' => 'changes' } } },
            tmp_changes
          )
        end
      end


      def test_month_and_year_from_date
        date = '1984-07-29'.to_date
        assert_equal('July 1984', month_and_year_from_date(date))
      end

      def test_month_name_needed?
        days = [['2016-01-22', []], ['2016-01-23', []], ['2016-01-24', []]]

        assert(month_name_needed?('2016-01-22', days))
        refute(month_name_needed?('2016-01-24', days))

        days = [['2016-01-22', []], ['2016-01-23', []], ['2016-01-24', []]]

        assert(month_name_needed?('2016-02-01', days))
        refute(month_name_needed?('2016-02-02', days))
      end

      def test_calendar_day_number
        assert_equal(2, calendar_day_number('2042-04-02'))
      end

      def test_calendar_day_classes
        start_date = Time.zone.now.to_date
        day = start_date.strftime('%Y-%m-%d')

        start_of_week = start_date.beginning_of_week(:sunday) == start_date
        classes = calendar_day_classes(day)
        odd_month = start_date.month.odd?

        assert(classes.include?('calendar__day'))
        assert_equal(odd_month, classes.include?('calendar__day--odd-month'))
        assert(classes.include?('calendar__day--today'))
        assert_equal(start_of_week, classes.include?('calendar__day--start-of-week'))
      end
    end
  end
end
