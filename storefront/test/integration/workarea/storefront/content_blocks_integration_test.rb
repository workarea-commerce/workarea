require 'test_helper'

module Workarea
  module Storefront
    class ContentBlocksIntegrationTest < Workarea::IntegrationTest
      def test_content_blocks_render_with_defaults
        # For sample data
        create_asset
        create_taxon
        create_product
        create_category
        create_page

        content = Content.for('home_page')

        Configuration::ContentBlocks.types.each do |block_type|
          content.blocks.build(
            type: block_type.slug,
            data: block_type.defaults
          )
        end

        content.save!

        get storefront.root_path
        assert(response.ok?)
      end

      def test_previewing_new_content_block
        set_current_user(create_user(super_admin: true))

        get storefront.new_content_block_path(
          type_id: 'html',
          content_id: create_content.id
        )

        assert(response.ok?)
      end

      def test_showing_a_content_block
        set_current_user(create_user(super_admin: true))
        content = create_content
        block = content.blocks.build(
          type: :html,
          data: { 'html' => 'foo' }
        )
        content.save!

        get storefront.content_block_path(block)
        assert(response.ok?)
      end

      def test_showing_a_content_draft
        set_current_user(create_user(super_admin: true))
        content = create_content
        block = content.blocks.build(
          type: :html,
          data: { 'html' => 'foo' }
        )
        content.save!

        draft = block.to_draft.tap(&:save!)
        get storefront.draft_content_block_path(draft)
        assert(response.ok?)
      end
    end
  end
end
