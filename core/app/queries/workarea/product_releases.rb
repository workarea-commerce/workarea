module Workarea
  class ProductReleases
    attr_reader :product

    def initialize(product)
      @product = product
    end

    def releases
      changesets
        .uniq(&:release)
        .flat_map { |cs| [cs.release] + cs.release.scheduled_after }
        .uniq
    end

    # All {Releasable}s that could affect the product's Elasticsearch document
    # should add their changesets to this method.
    #
    # @example Add to the changesets affecting a product in a decorator
    #   def changesets
    #     super.merge(SomeReleasable.for_product(product.id).changesets_with_children)
    #   end
    #
    # @return [Mongoid::Criteria]
    #
    def changesets
      criteria = product.changesets_with_children
      pricing_skus.each { |ps| criteria.merge!(ps.changesets_with_children) }
      criteria.merge!(FeaturedProducts.changesets(product.id))
      criteria.includes(:release)
    end

    def pricing_skus
      Pricing::Sku.in(id: product.skus).to_a
    end
  end
end
