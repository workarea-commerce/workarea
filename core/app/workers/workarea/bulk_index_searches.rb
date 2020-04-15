module Workarea
  class BulkIndexSearches
    include Sidekiq::Worker

    class << self
      def perform(ids = popular_searches.pluck(:id))
        ids.each_slice(Workarea.config.bulk_index_batch_size) do |group|
          perform_by_models(Metrics::SearchByWeek.in(id: group).to_a)
        end
      end

      def popular_searches
        Metrics::SearchByWeek
          .last_week
          .has_results
          .most_searched
          .limit(Workarea.config.max_searches_to_index)
      end

      def perform_by_models(searches)
        Search::Storefront.bulk do
          searches.map do |model|
            Search::Storefront::Search.new(model).as_bulk_document
          end
        end
      end
    end

    def perform(*)
      self.class.perform
    end
  end
end
