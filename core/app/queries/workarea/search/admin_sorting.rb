module Workarea
  module Search
    module AdminSorting
      def self.available_sorts
        Sort::Collection.new(
          Sort.relevance,
          Sort.modified,
          Sort.name_asc,
          Sort.newest,
          Sort.oldest
        )
      end

      def current_sort
        AdminSorting.available_sorts.find(params[:sort])
      end

      def default_admin_sort
        [{ updated_at: :desc }, { _score: :desc }]
      end

      def user_selected_sort
        [{ current_sort.field => current_sort.direction }]
      end

      def sort
        sort = super
        return sort unless sort.blank?

        if current_sort.field.present?
          user_selected_sort
        else
          default_admin_sort
        end
      end
    end
  end
end
