module Workarea
  class Metadata::ContentPage < Metadata

    # Provides a default value for use as the html page title using
    # the name of the page and its parent taxon if available.
    #
    # @example
    #   Sub-Category - Primary Taxon
    #
    # @return [String]
    #
    def title
      title = [model.name]
      taxon = model.taxon

      if taxon.present? && taxon.parent.present? && !taxon.parent.root?
        title << taxon.parent.name
      end

      title.join(' - ')
    end

    # Provides a default value for use as the html content meta
    # tag using an excerpt of the page's content blocks with a
    # length determined by the configurable max words.
    #
    # @return [String]
    #
    def description
      ExtractContentBlockText.new(content.blocks)
          .text
          .split(/\s+/)
          .first(max_words)
          .join(' ')
    end
  end
end
