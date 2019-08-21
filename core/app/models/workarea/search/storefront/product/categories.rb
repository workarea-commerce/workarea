module Workarea
  module Search
    class Storefront
      class Product
        module Categories
          extend ActiveSupport::Concern

          class_methods do
            def add_category(category)
              I18n.for_each_locale do
                category.reload

                if category.product_rules.present?
                  document = {
                    id: category.id,
                    query: Categorization.new(rules: category.product_rules).query
                  }

                  Storefront.current_index.save(document, type: 'category')
                end
              end
            end

            def delete_category(category_id)
              I18n.for_each_locale do
                current_index.delete(category_id, type: 'category')
              end

            rescue ::Elasticsearch::Transport::Transport::Errors::NotFound
              # doesn't matter we want it deleted
            end

            def find_categories(product)
              search_model = Product.new(product, skip_categorization: true)

              begin
                find_categories!(id: search_model.id)
              rescue
                begin
                  find_categories!(document: search_model.as_document)
                rescue ::Elasticsearch::Transport::Transport::ServerError
                  []
                end
              end
            end

            def find_categories!(options)
              results = current_index.search(
                size: Workarea.config.product_categories_by_rules_max_count,
                query: {
                  percolate: options.merge(
                    field: 'query',
                    index: current_index.name,
                    type: Storefront.type,
                    document_type: 'category'
                  )
                }
              )

              results['hits']['hits'].map { |h| h['_id'] }
            end
          end

          # A list of the {Catalog::Category} IDs that the product was featured
          # in. Used for adding featured products to category listings in
          # addition to the products that match on rules.
          #
          # @return [Array<String>]
          #
          def category_id
            categorization.manual
          end

          # List of categories for the product.
          #
          # @return [Array<Workarea::Categorization>]
          #
          def categorization
            return Workarea::Categorization.new if options[:skip_categorization]
            @categorization ||= Workarea::Categorization.new(model)
          end
        end
      end
    end
  end
end
