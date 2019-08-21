module Workarea
  module Admin
    class SearchViewModel < ApplicationViewModel
      def results
        @results ||= PagedArray.from(
          persisted_results.map do |model|
            ApplicationController.wrap_in_view_model(
              model,
              view_model_options_for(model)
            )
          end,
          model.results.page,
          model.results.per_page,
          total
        )
      end

      def total
        model.results.total - (model.results.length - persisted_results.length)
      end

      def sort
        if options[:sort].blank?
          options[:q].present? ? Sort.relevance : Sort.modified
        else
          Search::AdminSearch.available_sorts.find(options[:sort])
        end
      end

      def sorts
        Search::AdminSearch.available_sorts.map { |s| [s.name, s.slug] }
      end

      def facets
        results = model.facets.reject(&:useless?)
        results.reject! { |f| f.system_name == 'type' } unless options[:show_type]
        results
      end

      def facet_selections
        @facet_selections ||= facets.reduce({}) do |selected, facet|
          facet.results.keys.each do |key|
            if facet.selected?(key)
              selected[facet] ||= []
              selected[facet] << key
            end
          end

          selected
        end
      end

      def filters
        @filters ||= model.filters.reject(&:useless?)
      end

      def applied_filters?
        facet_selections.any? || filters.any?
      end

      def toggle_facets?
        facets.length > 2
      end

      private

      def view_model_options_for(model)
        source = result_sources.detect { |s| model.id.to_s.in?(s['id']) }
        options.merge(source: source)
      end

      def result_sources
        @result_sources ||=
          model.response['hits']['hits'].map { |r| r['_source'].except('model') }
      end

      def persisted_results
        classes = model.results.map(&:class).uniq

        if classes.one?
          # To fix N+1 where it's possible
          result_ids = model.results.map(&:id)
          persisted_ids = classes.first.any_in(id: result_ids).only(:id).map(&:id)
          model.results.select { |r| r.id.in?(persisted_ids) }
        else
          model.results.select { |r| r.class.where(id: r.id).exists? }
        end
      end
    end
  end
end
