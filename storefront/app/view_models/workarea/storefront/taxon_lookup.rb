module Workarea
  module Storefront
    module TaxonLookup
      # Return a list of taxons to render in a navigation content block.
      #
      # @param [Workarea::Navigation::Taxon]
      # @return [Array<Workarea::Navigation::Taxon>]
      #
      def find_taxons_for(start)
        return [] if start.blank?

        if start.has_children?
          start.children.select(&:active?)
        elsif start.active? && !show_starting_taxon?
          [start]
        else
          []
        end
      end

      def taxons
        return [] unless starting_taxon.present?
        @taxons ||= find_taxons_for(starting_taxon)
      end

      def starting_taxon
        @starting_taxon ||= Navigation::Taxon.find(data['start'])
      rescue Mongoid::Errors::DocumentNotFound
        nil
      end

      def show_starting_taxon?
        data['show_starting_taxon'] && starting_taxon.present?
      end
    end
  end
end
