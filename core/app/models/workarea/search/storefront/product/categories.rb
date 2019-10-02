module Workarea
  module Search
    class Storefront
      class Product
        module Categories
          extend ActiveSupport::Concern

          # TODO remove these in v3.6
          class_methods do
            Workarea.deprecation.deprecate_methods(
              self,
              add_category: 'Use `Search::Storefront::CategoryQuery.new(category).create` instead',
              delete_category: 'Use `Search::Storefront::CategoryQuery.new(category).delete` instead',
              find_categories: 'Use `Workarea::Search::Storefront::CategoryQuery.find_by_product` instead'
            )

            def add_category(category)
              CategoryQuery.new(category).create
            end

            def delete_category(category_id)
              CategoryQuery.new(category_id).delete
            end

            def find_categories(product)
              CategoryQuery.find_by_product(product)
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
