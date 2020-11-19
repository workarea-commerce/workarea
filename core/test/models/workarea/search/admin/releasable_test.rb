require 'test_helper'

module Workarea
  module Search
    class Admin
      class ReleasableTest < TestCase
        class Foo < Admin
          include Releasable
        end

        def test_facets
          releasable = create_page(name: 'Foo', active_segment_ids: %w(foo bar))
          content = Workarea::Content.for(releasable)
          content.blocks.create!(type: 'html', active_segment_ids: %w(bar baz))

          release_one = create_release
          release_two = create_release
          release_three = create_release

          release_one.as_current { releasable.update_attributes!(name: 'Bar') }
          release_two.as_current { content.update_attributes!(browser_title: 'Foo') }
          release_three.as_current { releasable.update_attributes!(name: 'Bar') }
          release_three.update_attributes!(published_at: Time.current)

          search_model = Foo.new(releasable)
          assert_equal(search_model.facets[:active_by_segment], %w(foo bar baz))
          assert_includes(search_model.facets[:upcoming_changes], release_one.id)
          assert_includes(search_model.facets[:upcoming_changes], release_two.id)
          refute_includes(search_model.facets[:upcoming_changes], release_three.id)
        end

        def test_upcoming_changes
          release_one = create_release
          release_two = create_release

          product = create_product

          release_one.as_current { product.update!(name: 'Changed Name') }
          release_two.as_current { product.variants.first.update!(name: 'Changed Name') }

          search_model = Foo.new(product)
          assert_includes(search_model.facets[:upcoming_changes], release_one.id)
          assert_includes(search_model.facets[:upcoming_changes], release_two.id)
        end
      end
    end
  end
end
