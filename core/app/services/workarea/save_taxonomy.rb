module Workarea
  class SaveTaxonomy
    def self.build(navigable)
      result = navigable.taxon || navigable.build_taxon(name: navigable.name)

      # These two fields necessary because Mongoid isn't setting them
      # automatically :(
      result.navigable_type = navigable.class.name
      result.navigable_id = navigable.id
      result
    end

    def initialize(taxon, params)
      @taxon = taxon
      @params = params
    end

    def perform
      @taxon.update_attributes!(parent_id: @params[:parent_id])
      @taxon.move_to_position(@params[:position]) if @params[:position].present?

      set_taxonomy_slug
    end

    def set_taxonomy_slug
      Release.with_current(nil) do
        Sidekiq::Callbacks.disable(RedirectNavigableSlugs) do
          slug = FindTaxonomySlug.new(@taxon.navigable, @taxon).slug
          @taxon.navigable.update_attributes!(slug: slug) if slug.present?
        end
      end
    end

    def top_level?
      @taxon.parent == Navigation::Taxon.root
    end
  end
end
