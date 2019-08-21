module Workarea
  module Admin
    class HelpSearchViewModel < SearchViewModel
      def top_categories
        @top_categories ||= Help::Article.top_categories
      end

      def top_articles_by_category
        @top_articles_by_category ||= top_categories.reduce({}) do |memo, category|
          articles = Help::Article.in_category(category).recent.top.to_a
          memo[category] = articles if articles.present?
          memo
        end
      end
    end
  end
end
