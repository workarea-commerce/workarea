module Workarea
  module Navigation
    class Breadcrumbs
      include Enumerable

      attr_reader :navigable, :last, :taxon_ids
      delegate :each, :length, :blank?, :present?, :[], to: :collection

      def self.from_global_id(via, last: nil)
        navigable = GlobalID::Locator.locate(via)
        new(navigable, last: last)
      end

      def initialize(navigable, last: nil)
        @navigable = navigable
        @last = if last.class.include?(Navigable)
                  Taxon.new(
                    name: last.name,
                    navigable: last,
                    navigable_slug: last.slug,
                    parent: breadcrumb_taxons.last
                  )
                elsif last.present?
                  Taxon.new(name: last, parent: breadcrumb_taxons.last)
                end
      end

      def to_global_id
        return nil unless navigable.present?
        navigable.to_global_id.to_param
      end

      def last
        @last || breadcrumb_taxons.last
      end

      # Whether this link is selected in these breadcrumbs.
      # Used to determine whether we should add a selected class when rendering
      # navigation links.
      #
      # @param [Workarea::Navigation::Taxon]
      # @return [Boolean]
      #
      def selected?(taxon)
        map(&:id).map(&:to_s).include?(taxon.id.to_s)
      end

      def join(sep = ' ')
        collection.map(&:name).join(sep)
      end

      def collection
        @collection ||= if last != breadcrumb_taxons.last
                          breadcrumb_taxons + [last]
                        else
                          breadcrumb_taxons
                        end
      end

      private

      def breadcrumb_taxons
        navigable.try(:taxon).try(:ancestors_and_self) || []
      end
    end
  end
end
