# frozen_string_literal: true
# For some reason, loading Search::Storefront::Product doesn't get triggered
# require_dependency removed: Zeitwerk autoloads app/ files

module Workarea
  module Search
    class Storefront
      class CategoryQuery
        attr_reader :category

        class << self
          def find_by_product(product)
            product = product.in_release(Release.current) if product.persisted?
            search_model = Product.new(product, skip_categorization: true)

            find!(document: search_model.as_document)
          rescue ::Elasticsearch::Transport::Transport::Errors::NotFound,
                 ::Elasticsearch::Transport::Transport::Errors::ServiceUnavailable,
                 ::Elasticsearch::Transport::Transport::ServerError
            []
          end

          def percolate_document_type
            # ES 7+ removed mapping types. ES 6 still supports a single type.
            version = Workarea.elasticsearch.info.dig('version', 'number').to_s
            major = Integer(version.split('.').first)
            major < 7 ? '_doc' : nil
          rescue StandardError
            nil
          end

          def find!(options)
            percolate_options = options.merge(
              field: 'query',
              index: Storefront.current_index.name
            )

            # ES 6 still has mapping types but Workarea stores percolator docs
            # under the single `_doc` type. Using the legacy `category` type
            # causes percolate queries to return no matches.
            if (doc_type = percolate_document_type).present?
              percolate_options[:document_type] = doc_type
            end

            results = Storefront.current_index.search(
              size: Workarea.config.product_categories_by_rules_max_count,
              query: {
                percolate: percolate_options
              },
              post_filter: if Release.current.blank?
                {
                  bool: {
                    minimum_should_match: 1,
                    should: [
                      { term: { release_id: 'live' } },
                      { bool: { must_not: { exists: { field: 'release_id' } } } } # for upgrade compatiblity
                    ]
                  }
                }
              else
                {
                  bool: {
                    minimum_should_match: 1,
                    should: [
                      { term: { release_id: Release.current.id } },
                      {
                        bool: {
                          must_not: [{ term: { changeset_release_ids: Release.current.id } }],
                          must: [
                            {
                              bool: {
                                minimum_should_match: 1,
                                should: [
                                  { term: { release_id: 'live' } },
                                  { bool: { must_not: { exists: { field: 'release_id' } } } } # for upgrade compatiblity
                                ]
                              }
                            }
                          ]
                        }
                      }
                    ]
                  }
                }
              end
            )

            results['hits']['hits'].map { |h| h['_id'].split('-').first }
          end
        end

        def initialize(category)
          @category = category
        end

        def update
          delete
          create unless category.product_rules.blank?
        end

        def create
          I18n.for_each_locale do
            create_live
            create_releases
          end
        end

        def delete
          I18n.for_each_locale do
            begin
              Storefront.current_index.delete(category.id, refresh: true)
            rescue ::Elasticsearch::Transport::Transport::Errors::NotFound
              # doesn't matter we want it deleted
            end
          end
        end

        private

        def create_live
          Release.without_current do
            category.reload

            if category.product_rules.present?
              document = {
                id: category.id,
                release_id: 'live',
                changeset_release_ids: changesets.map(&:release_id).uniq,
                query: Workarea::Search::Categorization.new(rules: category.product_rules).query
              }

              Storefront.current_index.save(document, refresh: true)
            end
          end
        end

        def create_releases
          changesets.each do |changeset|
            changeset.release.as_current do
              category.reload

              if category.product_rules.present?
                document = {
                  id: "#{category.id}-#{changeset.release_id}",
                  release_id: changeset.release_id,
                  query: Workarea::Search::Categorization.new(rules: category.product_rules).query
                }

                Storefront.current_index.save(document, refresh: true)
              end
            end
          end
        end

        def changesets
          @changesets ||= Release::Changeset
            .where(releasable_type: ProductRule.name)
            .any_in(releasable_id: category.product_rules.map(&:id))
            .includes(:release)
            .select(&:release)
        end
      end
    end
  end
end
