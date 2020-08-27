require 'test_helper'

module Workarea
  module Admin
    class HelpArticlesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_can_create_a_help_article
        post admin.help_index_path,
          params: {
            help_article: {
              name: 'Test Article',
              thumbnail: product_image_file_path,
              category: 'FAQs',
              matching_url: '/admin',
              summary: 'Summary',
              body: 'Nice body.'
            }
          }

        assert_equal(1, Help::Article.count)

        help_article = Help::Article.first
        assert_equal('Test Article', help_article.name)
        assert(help_article.thumbnail.present?)
        assert_equal('FAQs', help_article.category)
        assert_equal('/admin', help_article.matching_url)
        assert_equal('Summary', help_article.summary)
        assert_equal('Nice body.', help_article.body)
      end

      def test_can_update_a_help_article
        help_article = create_help_article(
          name: 'Test Article',
          category: 'FAQs',
          body: 'Nice body.'
        )

        patch admin.help_path(help_article),
          params: {
            help_article: {
              name: 'Foo Article',
              category: 'Howto',
              matching_url: '/admin',
              summary: 'Summary',
              body: 'Nicer body.'
            }
          }

        help_article.reload
        assert_equal('Foo Article', help_article.name)
        assert_equal('Howto', help_article.category)
        assert_equal('/admin', help_article.matching_url)
        assert_equal('Summary', help_article.summary)
        assert_equal('Nicer body.', help_article.body)
      end

      def test_can_destroy_a_help_article
        help_article = create_help_article(
          name: 'Test Article',
          category: 'FAQs',
          body: 'Nice body.'
        )

        delete admin.help_path(help_article)
        assert(Help::Article.empty?)
      end
    end
  end
end
