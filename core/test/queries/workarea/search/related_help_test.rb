require 'test_helper'

module Workarea
  module Search
    class RelatedHelpTest < TestCase
      include SearchIndexing

      def test_query
        one = create_help_article(
          name: 'Test Article',
          category: 'FAQs',
          body: 'Nice body.'
        )

        two = create_help_article(
          name: 'Related Test Article',
          category: 'FAQs',
          body: 'Nice article body.'
        )

        three = create_help_article(
          name: 'Foo',
          category: 'Howto'
        )

        [one, two, three].each { |a| Workarea::Search::Help.new(a).save }

        results = Search::RelatedHelp.new(ids: [one.id]).results
        assert_equal(1, results.length)
        assert_equal(two, results.first)

        query = Search::RelatedHelp.new(for_url: '/admin')
        assert_equal([], query.results)
      end

      def test_results_with_url_matching
        base = create_help_article(
          name: 'Test Article',
          category: 'FAQs',
          body: 'Nice body.'
        )

        one = create_help_article(
          name: 'Unrelated',
          category: 'Howto',
          matching_url: '/admin/catalog_products',
          body: 'Nice body.'
        )

        two = create_help_article(
          name: 'Related Test Article',
          category: 'FAQs',
          body: 'Nice article body.'
        )

        three = create_help_article(
          name: 'Unrelated',
          category: 'Howto',
          body: 'Unrelated text.'
        )

        [base, one, two, three].each { |a| Workarea::Search::Help.new(a).save }

        query = Search::RelatedHelp.new(
          ids: [base.id],
          for_url: '/admin/catalog_products'
        )

        assert_equal(2, query.results.length)
        assert_equal(one, query.results.first)
        assert_equal(two, query.results.second)
      end

      def test_results
        Workarea.config.max_admin_related_help.times do
          create_help_article(
            name: 'Test Article',
            category: 'FAQs',
            body: 'Nice body.'
          )
        end

        Workarea.config.max_admin_related_help.times do
          create_help_article(
            name: 'Test Article',
            category: 'FAQs',
            body: 'Nice body.',
            matching_url: '/admin'
          )
        end

        query = Search::RelatedHelp.new(
          like_text: 'test',
          for_url: '/admin'
        )

        assert_equal(Workarea.config.max_admin_related_help, query.results.length)
      end
    end
  end
end
