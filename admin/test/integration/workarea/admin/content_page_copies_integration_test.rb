require 'test_helper'

module Workarea
  module Admin
    class ContentPageCopiesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_create
        content_page = create_page(
          id: 'foo123'
        )
        content = Content.for(content_page)
        content.blocks.build(
          type_id: :html,
          data: { html: '<p>Test!</p>' }
        )
        content.save!

        post admin.content_page_copies_path,
          params: {
            source_id: content_page.id,
            page: {
              active: false,
              id: 'bar345'
            }
          }

        new_content_page = Content::Page.find('bar345')

        assert_redirected_to(
          admin.edit_create_content_page_path(
            new_content_page,
            continue: true
          )
        )

        assert_equal("#{content_page.slug}-1", new_content_page.slug)
        assert_equal(
          '<p>Test!</p>',
          new_content_page.content.blocks.first.data[:html]
        )
      end
    end
  end
end
