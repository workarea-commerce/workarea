require 'test_helper'

module Workarea
  module Admin
    class HelpSearchViewModelTest < TestCase
      def test_returns_the_recent_articles_in_each_category
        howto = Array.new(3) do
          create_help_article(name: 'Foo', category: 'Howto')
        end

        feature = Array.new(3) do
          create_help_article(name: 'Foo', category: 'Feature')
        end

        popular = Array.new(3) do
          create_help_article(name: 'Foo', category: 'Popular')
        end

        view_model = HelpSearchViewModel.new(Search::HelpSearch.new)
        results = view_model.top_articles_by_category

        assert_equal(howto.reverse, results['Howto'])
        assert_equal(feature.reverse, results['Feature'])
        assert_equal(popular.reverse, results['Popular'])
      end

      def test_does_not_include_empty_categories
        create_help_article(name: 'Foo', category: 'Popular').destroy

        view_model = HelpSearchViewModel.new(Search::HelpSearch.new)
        assert(view_model.top_articles_by_category.empty?)
      end
    end
  end
end
