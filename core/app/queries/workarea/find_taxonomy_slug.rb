module Workarea
  class FindTaxonomySlug
    def initialize(navigable, taxon = nil)
      @navigable = navigable
      @taxon = taxon || navigable.taxon
    end

    def slug
      return unless @taxon.present?

      taxons = @taxon.ancestors_and_self
      taxons.shift # remove the first, root taxon

      slug =
        taxons
          .map { |t| t.navigable.try(:name) || t.name }
          .compact
          .map { |name| name.delete("'").parameterize }
          .join('-')

      FindUniqueSlug.new(@navigable, slug).slug
    end
  end
end
