require 'test_helper'

module Workarea
  module Admin
    class FacetsHelperTest < ViewTest
      def test_facet_value_display_name
        facet = Workarea::Search::Facet.new(nil, 'tags')
        assert_equal('bar_baz', facet_value_display_name(facet, 'bar_baz'))

        facet = Workarea::Search::Facet.new(nil, 'colors')
        assert_equal('Bar Baz', facet_value_display_name(facet, 'bar_baz'))

        facet = Workarea::Search::Facet.new(nil, 'upcoming_changes')
        release = create_release(name: 'Foo Release')
        assert_equal('Foo Release', facet_value_display_name(facet, release.id))
        assert_nil(facet_value_display_name(facet, 'bar_baz'))

        facet = Workarea::Search::Facet.new(nil, 'active_by_segment')
        segment = create_segment(name: 'Foo Segment')
        assert_equal('Foo Segment', facet_value_display_name(facet, segment.id))
        assert_equal(
          t('workarea.admin.segments.missing', id: 'bar'),
          facet_value_display_name(facet, 'bar')
        )
      end
    end
  end
end
