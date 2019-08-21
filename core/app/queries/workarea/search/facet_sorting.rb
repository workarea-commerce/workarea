module Workarea
  module Search
    class FacetSorting
      attr_reader :name

      def initialize(name)
        @name = name.to_sym
      end

      def to_h
        return dynamic_sorting if dynamic?
        return {} unless query_values[option].present?

        { order: query_values[option] }
      end

      def apply(results, size = full_result_size)
        return results unless dynamic?
        Hash[dynamic_option.call(name, results).first(size)]
      end

      def option
        @option ||=
          Workarea.config.search_facet_sorts[name].presence ||
          default_option
      end

      def dynamic_option
        @dynamic_option ||=
          if option.respond_to?(:call)
            option
          elsif option.try(:constantize).respond_to?(:call)
            option.constantize
          end
      rescue NameError
        @dynamic_option = nil
      end

      def dynamic?
        dynamic_option.present?
      end

      private

      def full_result_size
        Workarea.config.search_facet_dynamic_sorting_size
      end

      def dynamic_sorting
        { size: full_result_size, order: query_values[default_option] }
      end

      def default_option
        Workarea.config.search_facet_default_sort
      end

      # TODO: ES6 _term will change to _key
      def query_values
        {
          count: { '_count' => 'desc' },
          alphabetical_asc: { '_term' => 'asc' },
          alphabetical_desc: { '_term' => 'desc' }
        }
      end
    end
  end
end
