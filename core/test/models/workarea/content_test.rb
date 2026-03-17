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

    def test_for_string_is_idempotent
      Content.create_indexes
      Content.delete_all

      first = Content.for('home_page')
      second = Content.for('home_page')

      assert_equal(first.id, second.id)
      assert_equal(1, Content.where(name: 'Home Page').count)
    end

    def test_for_contentable_is_idempotent
      Content.create_indexes
      Content.delete_all

      foo = Foo.create!(name: 'Foo content')

      first = Content.for(foo)
      second = Content.for(foo)

      assert_equal(first.id, second.id)
      assert_equal(
        1,
        Content.where(contentable_type: 'Workarea::ContentTest::Foo', contentable_id: foo.id).count
      )
    end
  end
end
