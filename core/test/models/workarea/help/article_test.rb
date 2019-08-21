require 'test_helper'

module Workarea
  module Help
    class ArticleTest < TestCase
      def test_find_matching_url
        Article.create!(name: 'Blank', category: 'Howto')

        basic = create_help_article(
          name: 'Foo',
          category: 'Howto',
          matching_url: '/admin'
        )

        match = create_help_article(
          name: 'Bar',
          category: 'Howto',
          matching_url: '/admin/catalog_products/.*/edit'
        )

        assert_equal([basic], Article.find_matching_url('/admin'))

        result = Article.find_matching_url(
          '/admin/catalog_products/incredible-silk-hat/edit'
        )

        assert_equal([match], result)
      end

      def test_top_categories
        4.times do
          create_help_article(name: 'Foo', category: 'Howto')
        end

        3.times do
          create_help_article(name: 'Foo', category: 'Feature')
        end

        2.times do
          create_help_article(name: 'Foo', category: 'Popular')
        end

        create_help_article(name: 'Foo', category: 'FAQ')

        assert_equal(%w(Howto Feature Popular), Article.top_categories)
      end

      def test_id_should_be_a_parameterized_version_of_the_name
        article = create_help_article(name: 'Foo Bar Baz')
        assert_equal('foo-bar-baz', article.id)
      end
    end
  end
end
