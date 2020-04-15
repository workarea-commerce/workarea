module Workarea
  class BulkIndexProducts
    include Sidekiq::Worker

    sidekiq_options lock: :until_executing

    class << self
      def perform(ids = Catalog::Product.pluck(:id))
        ids.each_slice(Workarea.config.bulk_index_batch_size) do |group|
          perform_by_models(Catalog::Product.in(id: group).to_a)
        end
      end

      def perform_by_models(products)
        return if products.blank?
        products = Array.wrap(products)

        Search::Storefront.bulk do
          Search::ProductEntries.new(products).map(&:as_bulk_document)
        end

        Catalog::Product.in(id: products.map(&:id)).set(last_indexed_at: Time.current)
      end
      alias_method :perform_by_model, :perform_by_models
    end

    def perform(ids)
      self.class.perform(ids)
    end
  end
end
