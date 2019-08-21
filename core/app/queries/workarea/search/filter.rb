module Workarea
  module Search
    class Filter
      attr_reader :search, :name, :options
      delegate :params, :total, to: :search

      def initialize(search, name, options = nil)
        @search = search
        @name = name
        @options = options
      end

      def system_name
        @system_name ||= name.systemize
      end

      def display_name
        system_name.titleize
      end

      def current_value
        params[system_name]
      end

      def useless?
        !current_value.present?
      end

      def selected?(value)
        current_value.present? && current_value == value
      end

      def params_for(value)
        value = value.to_s
        result = valid_params

        if selected?(value)
          result.delete(system_name)
        else
          result[system_name] = value
        end

        result.delete_if { |_, v| v.blank? }
      end

      def valid_params
        valid_keys =
          Workarea.config.permitted_facet_params + search_facets + search_filters

        params.deep_dup.with_indifferent_access.slice(*valid_keys)
      end

      def query_clause
        raise NotImplementedError
      end

      private

      def search_facets
        return [] unless search.respond_to?(:facets)
        search.facets.map(&:system_name)
      end

      def search_filters
        return [] unless search.respond_to?(:filters)
        search.filters.map(&:system_name)
      end
    end
  end
end
