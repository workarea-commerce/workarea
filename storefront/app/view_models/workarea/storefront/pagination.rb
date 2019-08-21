module Workarea
  module Storefront
    module Pagination
      extend ActiveSupport::Concern

      included do
        delegate :page, :per_page, :total, to: :search_query
      end

      def search_query
        raise(
          NotImplementedError,
          "#{self.class} must implement #search_query for Pagination"
        )
      end

      def total_pages
        (total.to_f / per_page.to_f).ceil
      end

      def first_page?
        page == 1
      end

      def second_page?
        page == 2
      end

      def last_page?
        page == total_pages
      end

      def next_page
        page + 1 unless last_page?
      end

      def prev_page
        page - 1 unless first_page?
      end
    end
  end
end
