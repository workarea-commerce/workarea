module Workarea
  module Search
    # This class exists to provide plugins and host applications a single
    # point of modification for changing the logic around indexing products
    # See workarea-browse_option or workarea-package_products for example.
    #
    class ProductEntries
      include Enumerable
      delegate :any?, :empty?, :each, :size, to: :entries

      def initialize(products)
        @products = Array.wrap(products)
      end

      def entries
        @entries ||= @products.flat_map { |p| index_entries_for(p) }
      end

      def index_entries_for(product)
        Search::Storefront::Product.new(product)
      end
    end
  end
end
