module Workarea
  module Navigation
    class TaxonCache
      delegate :root, to: :@taxon

      def self.set(taxon)
        new(taxon).set
      end

      def initialize(taxon)
        @taxon = taxon
      end

      def set
        if @taxon.url?
          clear_navigable
        elsif @taxon.navigable? && @taxon.navigable.present?
          set_navigable_cache_values
        end

        ensure_navigable_slug
      end

      private

      def clear_navigable
        @taxon.navigable = nil
        @taxon.navigable_slug = nil
      end

      def set_navigable_cache_values
        @taxon.name = @taxon.navigable.name if @taxon.name.blank?
        @taxon.navigable_slug = @taxon.navigable.slug
      end

      def ensure_navigable_slug
        unless @taxon.navigable_slug.nil?
          @taxon.navigable_slug = @taxon.navigable_slug.parameterize
        end
      end
    end
  end
end
