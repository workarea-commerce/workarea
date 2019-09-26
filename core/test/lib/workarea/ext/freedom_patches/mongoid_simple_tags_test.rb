require 'test_helper'

module Workarea
  class MongoidSimpleTagsTest < TestCase
    class Model
      include ApplicationDocument
      include Mongoid::Document::Taggable
    end

    setup :setup_model

    def setup_model
      @model = Model.create!(tags: %w(foo bar baz foo))
    end

    def test_tag_list_is_unique
      assert_equal 'foo, bar, baz', @model.tag_list

      @model.tag_list = 'foo, bar, baz, baz, bat'

      assert_equal('foo, bar, baz, bat', @model.tag_list)
    end

    def test_tags_are_unique
      assert_equal %w(foo bar baz), @model.tags

      @model.tags = %w(foo bar bar bar baz bat)

      assert_equal(%w(foo bar baz bat), @model.tags)
      assert(@model.update!(tags: %w(foo bar bar bar baz bat)))
      assert(%w(foo bar baz bat), @model.reload.tags)
    end
  end
end
