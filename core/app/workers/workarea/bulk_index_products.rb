module Workarea
  class BulkIndexProducts
    include Sidekiq::Worker

    sidekiq_options lock: :until_executing

    class << self
      def perform(ids = Catalog::Product.pluck(:id))
        ids.each_slice(100) do |group|
          perform_by_models(Catalog::Product.in(id: group).to_a)
        end
      end

      def perform_by_models(products)
        return if products.blank?

        documents = Search::ProductEntries.new(products).map(&:as_bulk_document)

        Search::Storefront.bulk(documents)
        products.each { |p| p.set(last_indexed_at: Time.current) }
      end
    end

    def perform(ids)
      self.class.perform(ids)
    end
  end
end
