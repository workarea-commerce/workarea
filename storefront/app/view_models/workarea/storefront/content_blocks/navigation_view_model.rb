module Workarea
  module Storefront
    module ContentBlocks
      class NavigationViewModel < ContentBlockViewModel
        # Return a list of taxons to render in a navigation content block.
        #
        # @param [Workarea::Navigation::Taxon]
        # @return [Array<Workarea::Navigation::Taxon>]
        #
        def find_taxons_for(start)
          return [] if start.blank?

          if start.has_children?
            start.children.select(&:active?)
          elsif start.active?
            [start]
          else
            []
          end
        end

        def taxons
          @taxons ||= find_taxons_for(starting_taxon)
        end

        def starting_taxon
          @starting_taxon ||= Navigation::Taxon.find(data['start'])
        end
      end
    end
  end
end
