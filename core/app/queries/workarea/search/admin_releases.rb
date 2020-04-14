module Workarea
  module Search
    class AdminReleases
      include Query
      include AdminIndexSearch
      include AdminSorting
      include Pagination

      document Search::Admin

      def self.available_sorts
        Sort::Collection.new(Sort.published_date)
      end

      def initialize(params = {})
        super(params.merge(type: 'release'))
      end

      def facets
        super + [TermsFacet.new(self, 'publishing')]
      end

      def filters
        super + [
          DateFilter.new(self, 'published_at', :gte),
          DateFilter.new(self, 'published_at', :lte)
        ]
      end

      def sort
        Array.wrap(super).tap do |sort|
          current_sort =
            self.class.available_sorts.detect { |s| s.to_s == params[:sort] }

          if current_sort.present? && current_sort.field.present?
            sort.prepend(current_sort.field => current_sort.direction)
          end
        end
      end
    end
  end
end
