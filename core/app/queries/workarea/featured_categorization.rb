module Workarea
  class FeaturedCategorization
    include Enumerable
    delegate :blank?, :present?, :size, :length, :to_a, to: :all

    def initialize(*product_ids)
      @product_ids = product_ids
    end

    def all
      @all ||= begin
        result = live

        categories_affected_by_current_release.each do |category|
          if product_featured_in_category?(category)
            result += [category] unless result.include?(category)
          else
            result -= [category]
          end
        end

        result
      end
    end

    def live
      @live ||= Catalog::Category.by_product(@product_ids).to_a
    end

    def categories_affected_by_current_release
      return [] if Release.current.blank?

      Catalog::Category.in(
        id: category_changesets_affecting_current_release.map(&:releasable_id)
      )
    end

    def category_changesets_affecting_current_release
      return [] if Release.current.blank?

      FeaturedProducts
        .changesets(*@product_ids)
        .where(releasable_type: Catalog::Category.name)
        .in(release_id: Release.current.preview.releases.map(&:id))
    end

    private

    def product_featured_in_category?(category)
      @product_ids.any? { |id| category.featured_product?(id) }
    end
  end
end
