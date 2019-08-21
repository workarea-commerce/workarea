require 'test_helper'

module Workarea
  class ContentTest < Workarea::TestCase
    class Foo
      include Mongoid::Document
      include Contentable

      field :name, type: String
    end

    setup do
      @content = create_content
    end

    def test_defaulting_to_the_contentable_name
      model = Foo.new(name: 'Foo content')
      assert_equal(Content.new(contentable: model).name, 'Foo content')
    end

    def test_finding_content_by_block_id
      block = @content.blocks.create!(type: 'html')

      assert_equal(@content, Content.from_block(block.id))
      assert_equal(@content, Content.from_block(block.id.to_s))
    end
  end
end
