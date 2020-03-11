module Workarea
  module Tasks
    module Search
      extend self

      def setup
        require 'sidekiq/testing/inline' unless ENV['INLINE'] == 'false'
        Workarea.config.bulk_index_batch_size = ENV['BATCH_SIZE'].to_i if ENV['BATCH_SIZE'].present?
      end

      def index_admin
        Workarea::QueuesPauser.with_paused_queues do
          Workarea::Search::Admin.reset_indexes!
        end

        Mongoid.models.each do |klass|
          next unless Workarea::Search::Admin.for(klass.first).present?

          klass.all.each_slice_of(Workarea.config.bulk_index_batch_size) do |models|
            Workarea::BulkIndexAdmin.perform_by_models(models)
          end
        end

        Workarea.config.jump_to_navigation.to_a.each do |tuple|
          Workarea::Search::Admin::Navigation.new(tuple).save
        end
      end

      def index_storefront
        Workarea::QueuesPauser.with_paused_queues do
          Workarea::Search::Storefront.reset_indexes!
          Workarea::Search::Storefront.ensure_dynamic_mappings
        end

        ensure_dynamic_mappings_for_current_product_filters

        index_storefront_categories
        index_storefront_content_pages
        index_storefront_products
        index_storefront_searches
      end

      def index_help
        Workarea::QueuesPauser.with_paused_queues do
          Workarea::Search::Help.reset_indexes!
        end

        Workarea::Help::Article.all.each_by(Workarea.config.bulk_index_batch_size) do |help_article|
          Workarea::Search::Help.new(help_article).save
        end
      end

      private

      # This code finds all unique filters for products so we can index a sample
      # product for each to ensure the dynamic mappings get created.
      #
      # This is necessary to fix mapping errors from Elasticsearch when trying
      # to index category percolations against fields which have no mapping.
      #
      def ensure_dynamic_mappings_for_current_product_filters
        map = %{
          function() {
            for (var key in this.filters.#{I18n.locale}) {
              emit(key, null);
            }
          }
        }
        reduce = 'function(key) { return null; }'
        results = Workarea::Catalog::Product.map_reduce(map, reduce).out(inline: 1)
        unique_filters = results.map { |r| r['_id'] }

        sample_products = unique_filters.reduce([]) do |memo, filter|
          filter = "filters.#{I18n.locale}.#{filter}"
          memo << Workarea::Catalog::Product.exists(filter => true).sample
        end

        sample_products.each do |product|
          Workarea::Search::Storefront::Product.new(product).save
        end
      end

      def index_storefront_categories
        Workarea::Catalog::Category.all.each_by(Workarea.config.bulk_index_batch_size) do |category|
          Workarea::Search::Storefront::CategoryQuery.new(category).create
          Workarea::Search::Storefront::Category.new(category).save
        end
      end

      def index_storefront_content_pages
        Workarea::Content::Page.all.each_by(Workarea.config.bulk_index_batch_size) do |page|
          Workarea::Search::Storefront::Page.new(page).save
        end
      end

      def index_storefront_products
        Workarea::BulkIndexProducts.perform
      end

      def index_storefront_searches
        Workarea::BulkIndexSearches.perform
      end
    end
  end
end
