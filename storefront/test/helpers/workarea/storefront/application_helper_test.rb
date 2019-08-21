require 'test_helper'

module Workarea
  module Storefront
    class ApplicationHelperTest < ViewTest
      def test_page_title
        assert(page_title('Test Title').starts_with?('Test Title'))
      end

      def test_render_message
        message_html = render_message('error', 'Foo', data: { bar: 'baz' })
        assert_includes(message_html, 'message--error')
        assert_includes(message_html, 'Error')
        assert_includes(message_html, 'Foo')
        assert_includes(message_html, "data-bar='baz'")

        message_html = render_message('success', title: 'Qux') { 'Bar' }
        assert_includes(message_html, 'message--success')
        assert_includes(message_html, 'Success')
        assert_includes(message_html, 'Bar')
        assert_includes(message_html, "title='Qux'")
      end
    end
  end
end
