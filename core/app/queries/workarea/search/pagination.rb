module Workarea
  module Search
    module Pagination
      def page
        tmp = params[:page].present? ? params[:page].to_i : 1
        tmp > 0 ? tmp : 1
      end

      def per_page
        return Workarea.config.per_page if params[:per_page].blank?

        tmp = params[:per_page].to_i
        tmp > 0 ? tmp : Workarea.config.per_page
      end

      def size
        super || per_page
      end

      def from
        size * (page - 1)
      end

      def results
        @paged_results ||= PagedArray.from(
          super,
          page,
          per_page,
          total
        )
      end

      def each_by(by, &block)
        i = 0

        while (results = get_each_by_results(by, i)) && results.present?
          results.each { |result| yield(result) }
          i += 1
        end
      end

      private

      def get_each_by_results(by, i)
        self.class.new(params.merge(page: i + 1, per_page: by)).results
      end
    end
  end
end
