require 'test_helper'

module Workarea
  module Admin
    class ApplicationHelperTest < ViewTest
      def request
        @request ||= ActionDispatch::TestRequest.new
      end

      def test_hash_editing_value
        test = ["A","B","C"]
        assert_equal('A,B,C', hash_editing_value(test))

        test = ["A\"","B","C"]
        assert_equal('"A""",B,C', hash_editing_value(test))
      end

      def test_hash_display_value
        test = ["A","B","C"]
        assert_equal('A, B, C', hash_display_value(test))

        test = ["A\"","B","C"]
        assert_equal('"A""", B, C', hash_display_value(test))
      end

      def test_relative_weekday
        assert_equal('Today', relative_weekday(Date.current))

        assert_equal('Yesterday', relative_weekday(Date.yesterday))

        weekdays = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
        assert(relative_weekday(2.days.ago.to_date).in?(weekdays))
        assert(relative_weekday(3.days.ago.to_date).in?(weekdays))
        assert(relative_weekday(4.days.ago.to_date).in?(weekdays))
      end

      def test_render_message
        message_html = render_message('error', 'Foo')
        assert_includes(message_html, 'message--error')
        assert_includes(message_html, 'Error')
        assert_includes(message_html, 'Foo')

        message_html = render_message('success') { 'Bar' }
        assert_includes(message_html, 'message--success')
        assert_includes(message_html, 'Success')
        assert_includes(message_html, 'Bar')
      end

      def card_classes
        classes = card_classes(:foo, :foo)
        assert_includes(classes, 'card--foo')
        assert_includes(classes, 'card--active')
        assert_includes(classes, 'card--button')

        classes = card_classes(:bar, :baz)
        assert_includes(classes, 'card--bar')
        refute_includes(classes, 'card--active')
        assert_includes(classes, 'card--button')

        classes = card_classes(:baz, nil)
        assert_includes(classes, 'card--baz')
        refute_includes(classes, 'card--active')
        refute_includes(classes, 'card--button')
      end

      def test_pagination_path_for
        request.path = '/foo'

        result = pagination_path_for(page: 1)
        assert_equal('/foo?page=1', result)

        request.query_parameters[:page] = 1
        result = pagination_path_for(page: 2)
        assert_equal('/foo?page=2', result)

        request.query_parameters[:asdf] = 'blah'
        request.query_parameters[:page] = 1
        result = pagination_path_for(page: 2)
        assert_equal('/foo?asdf=blah&page=2', result)
      end

      def test_workarea_release_notes_url
        result = workarea_release_notes_url('3.5.0')
        assert_equal(
          'https://developer.workarea.com/release-notes/workarea-3-5-0.html',
          result
        )
      end

      def test_duration_in_words
        assert_equal(
          t('workarea.duration.days', count: 2),
          duration_in_words(2.days)
        )

        assert_equal(
          [
            t('workarea.duration.years', count: 1),
            t('workarea.duration.months', count: 2),
            t('workarea.duration.days', count: 12),
          ].to_sentence,
          duration_in_words(2.months + 1.years + 12.days)
        )
      end
    end
  end
end
