require 'test_helper'

module Workarea
  module Admin
    class ContentIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_show_page_redirection
        get admin.content_path(create_content(name: 'Home Page'))
        refute(response.redirect?)

        page = create_page
        content = Content.for(page)
        get admin.content_path(content)
        assert(response.redirect?)
        assert_redirected_to(admin.edit_content_path(content))
      end
    end
  end
end
