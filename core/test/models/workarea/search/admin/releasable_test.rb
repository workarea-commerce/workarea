require 'test_helper'

module Workarea
  module Search
    class Admin
      class ReleasableTest < TestCase
        class Foo < Admin
          include Releasable
        end

        def test_facets
          releasable = create_page(name: 'Foo')

          release_one = create_release
          release_two = create_release
          release_three = create_release

          release_one.as_current { releasable.update_attributes!(name: 'Bar') }

          release_two.as_current do
            content = Workarea::Content.for(releasable)
            content.update_attributes!(browser_title: 'Foo')
          end

          release_three.as_current { releasable.update_attributes!(name: 'Bar') }
          release_three.update_attributes!(published_at: Time.current)

          search_model = Foo.new(releasable)
          assert_includes(search_model.facets[:upcoming_changes], release_one.id)
          assert_includes(search_model.facets[:upcoming_changes], release_two.id)
          refute_includes(search_model.facets[:upcoming_changes], release_three.id)
        end
      end
    end
  end
end
