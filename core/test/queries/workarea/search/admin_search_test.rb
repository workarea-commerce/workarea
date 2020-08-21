require 'test_helper'

module Workarea
  module Search
    class AdminSearchTest < IntegrationTest
      def test_autocomplete
        page = create_page(name: 'foo')

        search = AdminSearch.new(q: 'foo', autocomplete: true)
        assert_equal([page], search.results)
      end

      def test_not_including_navigation_in_results
        Workarea.config.jump_to_navigation.to_a.each do |tuple|
          Workarea::Search::Admin::Navigation.new(tuple).save
        end

        assert_equal(0, AdminSearch.new.total)
      end

      def test_filter_by_creation_date
        one = create_product(id: '1', created_at: Time.new(2016, 8, 24))
        two = create_product(id: '2', created_at: Time.new(2016, 8, 25))

        search = AdminSearch.new(
          created_at_greater_than: Time.new(2016, 8, 24).beginning_of_day.to_s(:iso8601),
          created_at_less_than: Time.new(2016, 8, 25).end_of_day.to_s(:iso8601)
        )

        assert_equal([two, one], search.results)

        search = AdminSearch.new(
          created_at_greater_than: Time.new(2016, 8, 25).beginning_of_day.to_s(:iso8601),
          created_at_less_than: Time.new(2016, 8, 25).end_of_day.to_s(:iso8601)
        )

        assert_equal([two], search.results)
      end

      def test_exclusions
        one = create_product(variants: [])
        two = create_product(variants: [])

        search = AdminSearch.new(exclude_ids: [Search::Admin.for(one).id])
        assert_equal(1, search.total)
        assert_equal([two], search.results)
      end

      def test_type_facets
        create_product(variants: [])
        create_page
        create_category
        create_release
        create_user

        search = AdminSearch.new
        type = search.facets.detect { |f| f.system_name == 'type' }

        assert_equal(
          {
            'category' => 1,
            'content_page' => 1,
            'product' => 1,
            'release' => 1,
            'user' => 1
          },
          type.results
        )
      end

      def test_default_sorting
        results = [
          create_product(variants: []),
          create_page,
          create_category,
          create_release,
          create_user
        ]

        search = AdminSearch.new
        assert_equal(results.reverse, search.results)
      end

      def test_default_sort_by_score
        # Unlike other admin searches (primarily indexes), we want searching to
        # default sort by score. Testing scores directly is unreliable so just
        # do a simple check here.
        assert_equal(
          [{ _score: :desc }, { updated_at: :desc }],
          AdminSearch.new.default_admin_sort
        )
      end

      def test_selected_sorting
        results = [
          create_product(name: 'A', variants: []),
          create_page(name: 'B'),
          create_category(name: 'C'),
          create_release(name: 'D')
        ]

        search = AdminSearch.new(sort: 'name_asc')
        assert_equal(results, search.results)
      end

      def test_keyword_matching
        keyword_match = create_product(id: '123-4')
        text_match = create_product(name: '123-4')

        search = AdminSearch.new(q: '123-4')
        assert_equal([keyword_match, text_match], search.results)
      end
    end
  end
end
