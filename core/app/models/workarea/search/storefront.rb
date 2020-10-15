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
        pieces = [type, model.id, model.try(:release_id)].reject(&:blank?)
        CGI.escape(pieces.join('-'))
      end

      def type
        model.class.name.demodulize.underscore
      end

      def slug
        model.slug
      end

      def release_id
        model.try(:release_id).presence || 'live'
      end

      # Whether the product is active. Stored as `:now` way for upgrade support
      # to v3.5 without requiring reindexing.
      #
      # return [Hash]
      #
      def active
        { now: model.active? }
      end

      def active_segment_ids
        model.try(:active_segment_ids)
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

      def changesets
        @changesets ||= Array.wrap(model.try(:changesets_with_children))
      end

      def releases
        Release.schedule_affected_by_changesets(changesets)
      end

      def as_document
        Release.with_current(release_id) do
          {
            id: id,
            type: type,
            slug: slug,
            active: active,
            active_segment_ids: active_segment_ids,
            release_id: release_id,
            changeset_release_ids: releases.map(&:id),
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
end
