module Workarea
  module Recommendation
    class ProductBased
      def initialize(product)
        @product = product
        @settings = Settings.find_or_initialize_by(id: @product.id)
      end

      def max_results
        # accommodate some missing or undisplayable products
        Workarea.config.per_page
      end

      def results
        @results ||=
          begin
            results = []

            @settings.sources.each do |source|
              results.push(*send(source))
              results.uniq!

              break if results.length >= max_results
            end

            results.take(max_results)
          end
      end

      def custom
        @settings.product_ids
      end

      def purchased
        @purchased ||= Recommendation::ProductPredictor
                        .new
                        .similarities_for(@product.id, limit: max_results)
      end

      def similar
        @similar ||= Search::RelatedProducts.new(product_ids: @product.id)
                      .results
                      .map { |r| r[:catalog_id] }
      end
    end
  end
end
