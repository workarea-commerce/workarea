require 'test_helper'

module Workarea
  module Admin
    class ContentBlocksIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def content
        @content ||= create_content
      end

      def area
        @area ||= 'header'
      end

      def block
        @block ||= content.blocks.create!(area: area, type: :html)
      end

      def test_creates_a_block
        post admin.content_area_blocks_path(content, area),
          params: { block: { type_id: :html, data: { 'html' => 'foo' } } }

        content.reload

        assert_equal(1, content.blocks.length)
        assert_equal(area, content.blocks.first.area)
        assert_equal(:html, content.blocks.first.type_id)
        assert_equal({ 'html' => 'foo' }, content.blocks.first.data)
      end

      def test_creating_blocks_without_publishing_authorization
        set_current_user(create_user(
                           admin: true,
                           releases_access: true,
                           store_access: true,
                           can_publish_now: false
        ))

        post admin.content_area_blocks_path(content, area),
          params: { block: { type_id: :html, data: { 'html' => 'foo' } } },
          headers: { 'HTTP_REFERER' => admin.edit_content_path(content) }

        content.reload
        assert_equal(0, content.blocks.length)
        assert_redirected_to(admin.edit_content_path(content))
        assert_equal(flash[:error], I18n.t('workarea.admin.publish_authorization.unauthorized'))


        content.update_attributes!(active: false)

        post admin.content_area_blocks_path(content, area),
          params: { block: { type_id: :html, data: { 'html' => 'foo' } } }

        content.reload

        assert_equal(1, content.blocks.length)
        assert_equal(area, content.blocks.first.area)
        assert_equal(:html, content.blocks.first.type_id)
        assert_equal({ 'html' => 'foo' }, content.blocks.first.data)
      end

      def test_updates_blocks
        patch admin.content_area_block_path(content, area, block),
          params: { block: { data: { 'html' => 'bar' } } }

        content.reload
        assert_equal(1, content.blocks.length)
        assert_equal(area, content.blocks.first.area)
        assert_equal(:html, content.blocks.first.type_id)
        assert_equal({ 'html' => 'bar' }, content.blocks.first.data)
      end

      def test_moves_blocks
        a = content.blocks.create!(area: 'body', type: :html)
        b = content.blocks.create!(area: 'body', type: :html)
        c = content.blocks.create!(area: 'body', type: :html)

        patch admin.move_content_area_blocks_path(content, area),
          params: {
            "block[#{c.id}]" => 0,
            "block[#{b.id}]" => 1,
            "block[#{a.id}]" => 2
          }

        content.reload
        assert_equal([c, b, a], content.blocks)
      end

      def test_copying_blocks
        block = content.blocks.create!(area: 'body', type: :html)

        post admin.copy_content_area_block_path(content, area, block)

        content.reload

        assert_equal(content.blocks.first.area, content.blocks.last.area)
        assert_equal(content.blocks.first.data, content.blocks.last.data)
        assert_equal(content.blocks.first.content, content.blocks.last.content)

        assert(content.blocks.last.position > content.blocks.first.position)
      end


      def test_destroys_blocks
        delete admin.content_area_block_path(content, area, block)
        content.reload
        assert(content.blocks.empty?)
      end

      def test_deactivates_blocks_when_deleting_on_a_release
        release = create_release

        post admin.release_session_path,
          params: { release_id: release.id }

        delete admin.content_area_block_path(content, area, block)

        Release.current = nil
        content.reload
        assert(content.blocks.first.active?)

        release.as_current do
          content.reload
          refute(content.blocks.first.active?)
        end
      end

    end
  end
end
