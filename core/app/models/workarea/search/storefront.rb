module Workarea
  module Search
    class Storefront
      include Elasticsearch::Document

      def self.ensure_dynamic_mappings
        # This ensures a bare-bones product mapping in Elasticsearch, which is
        # required for some functionality (e.g. categories in percolator).
        #
        # If there haven't been any products created, the mappings required for a
        # query or percolator may not be there.
        ensure_product_mappings
      end

      def self.ensure_product_mappings
        product = Workarea::Search::Storefront::Product.new(
          Workarea::Catalog::Product.new(id: 'null_product')
        )
        product.save
        Storefront.delete(product.id)
      end

      def id
        CGI.escape("#{type}-#{model.id}")
      end

      def type
        model.class.name.demodulize.underscore
      end

      def slug
        model.slug
      end

      # Whether the product is active for a given release state. Storing
      # active per-release allows accurate previewing of products in releases
      # on the storefront.
      #
      # return [Hash]
      #
      def active
        model.changesets.inject(now: model.active?) do |memo, changeset|
          active = if changeset.changeset['active'].respond_to?(:[])
            changeset.changeset['active'][I18n.locale]
          else
            !!changeset.changeset['active']
          end

          memo[changeset.release_id.to_s] = active
          memo
        end
      end

      def facets
        {}
      end

      def numeric
        {}
      end

      def keywords
        {}
      end

      def sorts
        {}
      end

      def content
        {}
      end

      def cache
        {}
      end

      def suggestion_content
        nil
      end

      def as_document
        {
          id: id,
          type: type,
          slug: slug,
          active: active,
          suggestion_content: suggestion_content,
          created_at: model.created_at,
          updated_at: model.updated_at,
          facets: facets,
          numeric: numeric,
          keywords: keywords,
          sorts: sorts,
          content: content,
          cache: cache
        }
      end
    end
  end
end
