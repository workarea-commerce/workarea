require 'test_helper'

module Workarea
  class GenerateContentMetadataTest < TestCase
    def test_perform
      home_page = Content.for('home_page')
      category = create_category(name: 'Test Category')
      page = create_page(name: 'Test Page')
      taxon = create_taxon(name: 'Test Category', navigable: category)
      create_taxon(parent: taxon, navigable: page)
      page_content = Content.for(page)
      page_content.blocks.create!(
        type: 'html',
        data: { 'html' => 'foo bar baz qux qoo'}
      )

      GenerateContentMetadata.new.perform

      category.reload
      assert(category.content.browser_title.present?)
      assert(category.content.meta_description.present?)

      page.reload
      assert(page.content.browser_title.present?)
      assert(page.content.meta_description.present?)

      home_page.reload
      assert(home_page.browser_title.present?)
      assert(home_page.meta_description.present?)
    end
  end
end
