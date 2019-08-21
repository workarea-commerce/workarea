require 'test_helper'

module Workarea
  class IndexHelpTest < Workarea::TestCase
    include TestCase::SearchIndexing

    def test_article_indexing
      article = create_help_article

      IndexHelp.new.perform(article.id)
      assert_equal(Search::Help.count, 1)

      article.destroy
      IndexHelp.new.perform(article.id)
      assert(Search::Help.count.zero?)
    end
  end
end
