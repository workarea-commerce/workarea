require 'test_helper'

module Workarea
  class ExtractContentBlockTextTest < TestCase
    def test_handles_multiple_blocks
      blocks = [
        Content::Block.new(
          data: { 'foo' => 'one two three four five' }
        ),
        Content::Block.new(
          data: { 'foo' => 'six seven eight nine ten' }
        )
      ]

      result = ExtractContentBlockText.new(blocks).text
      assert_equal('one two three four five six seven eight nine ten', result)
    end

    def test_strips_tags_from_results
      block = Content::Block.new(
        data: { 'foo' => 'one two three four <strong>five</strong>' }
      )

      result = ExtractContentBlockText.new(block).text
      assert_equal('one two three four five', result)
    end

    def test_only_includes_values_with_more_than_5_words
      block = Content::Block.new(data: { 'foo' => 'bar' })
      result = ExtractContentBlockText.new(block).text
      assert_equal('', result)
    end

    def test_ignores_urls
      block = Content::Block.new(
        data: { 'foo' => 'http://www.workarea.com/commerce-solutions/the-platform/core-technology/' }
      )

      result = ExtractContentBlockText.new(block).text
      assert_equal('', result)
    end

    def test_ignores_asset_urls
      block = Content::Block.new(
        data: { 'foo' => '/media/W1siZiIsIjIwMTYvMDcvMTIvOW9yd2xtMT/foo_bar.png?sha=123' }
      )

      result = ExtractContentBlockText.new(block).text
      assert_equal('', result)
    end

    def test_handles_non_strings
      bson_id = BSON::ObjectId.from_string('565c81f342656e8c71000000')
      block = Content::Block.new(data: { 'foo' => bson_id })

      result = ExtractContentBlockText.new(block).text
      assert_equal('', result)
    end
  end
end
