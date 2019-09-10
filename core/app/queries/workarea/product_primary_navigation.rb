module Workarea
  class ProductPrimaryNavigation
    def initialize(product, options = {})
      @product = product
      @options = options
    end

    def name
      if main_nav_taxon.present?
        main_nav_taxon.name
      elsif oldest_category.present?
        oldest_category.name
      else
        ''
      end
    end

    def main_nav_taxon
      return nil unless highest_category.try(:taxon).try(:ancestors).present?
      highest_category.taxon.ancestors_and_self.second
    end

    def highest_category
      @highest_category ||= categories
                              .select { |c| c.taxon.present? }
                              .sort { |a, b| a.taxon.depth <=> b.taxon.depth }
                              .first
    end

    def oldest_category
      categories.sort { |a, b| a.created_at <=> b.created_at }.first
    end

    private

    def categories
      @categories ||=
        (@options[:categories] || Categorization.new(@product).to_models)
          .tap(&method(:load_taxons))
    end

    def load_taxons(categories)
      taxons = Navigation::Taxon
        .where(navigable_type: Catalog::Category.name)
        .in(navigable_id: categories.map(&:id))
        .map { |taxon| [taxon.navigable_id, taxon] }
        .to_h

      categories.each { |cat| cat.set_relation(:taxon, taxons[cat.id]) }
    end
  end
end
