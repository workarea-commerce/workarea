module Workarea
  class Metadata::CatalogCategory < Metadata

    # Provides a default value for use as the html page title using
    # the name of the category and its top selling sub-categories
    #
    # @example Top selling categories
    #   Men: Shirts, Pants, Suits, and Coats
    #
    # @return [String]
    #
    def title
      if top_taxons.present?
        "#{model.name}: #{top_taxons.map(&:name).to_sentence}"
      end
    end

    # Provides a default value for use as the html content meta
    # tag using the top selling sub-categories (based on
    # navigation structure)
    #
    # @example Top selling categories
    #   Shop Men for a great selection including Shirts, Pants,
    #   Suits, and Coats
    #
    # @return [String]
    #
    def description
      if top_taxons.present?
        description = [
          I18n.t('workarea.metadata.shop_selection', name: model.name)
        ]

        description << top_taxons.map(&:name).to_sentence
        description.join(' ')
      end
    end

    private

    def top_taxons
      (model.try(:taxon).try(:children) || []).take(4)
    end
  end
end
