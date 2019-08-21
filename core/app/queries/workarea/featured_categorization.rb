module Workarea
  class FeaturedCategorization
    include Enumerable
    delegate :blank?, :present?, :size, :length, :to_a, to: :all

    def initialize(product)
      @product = product
    end

    def all
      @all ||= begin
        result = live

        categories_affected_by_current_release.each do |category|
          if category.featured_product?(@product.id)
            result += [category] unless result.include?(category)
          else
            result -= [category]
          end
        end

        result
      end
    end

    def live
      @live ||= Catalog::Category.by_product(@product.id).to_a
    end

    def categories_affected_by_current_release
      return [] if Release.current.blank?

      FeaturedProducts
        .changesets(@product.id)
        .where(releasable_type: Catalog::Category.name)
        .in(release_id: releases_affecting_current_release.map(&:id))
        .map(&:releasable)
    end

    def releases_affecting_current_release
      return [] if Release.current.blank?
      Release.current.scheduled_before + [Release.current]
    end
  end
end
